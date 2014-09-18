module Quasar
  
  # Grabs schedules from our cinemas and then saves
  # those schedules to the database.
  #
  # For new movies, this class creates "stub records"
  # which are temporary movie records and then schedules
  # an updater afterwards which will grabe movie information
  # from our sources.
  class ScheduleFetcher

    attr_reader :schedules

    # Initialization/constructor.
    # Sets the source of schedules and the client class.
    # Pass in a cinema model to start.
    def initialize(cinema)
      @cinema = cinema
      @klass = "Quasar::Scrapers::#{cinema.fetcher}".constantize
    end

    # Performs the processing of schedules
    # and recording to the database.
    def perform

      unless @cinema.fetcher.nil?
        @fetcher = @klass.new
        @schedules = @fetcher.get_schedules
        process_movies
      else
        raise "Cannot fetch schedules for #{@cinema.name}. Scraper is nil."
      end

    end

    private

      # Processes the movie titles, performs sanity checks
      # and creates new records if they don't exist yet.
      def process_movies

        # Setup sanitizer
        require 'html/sanitizer'
        @sanitizer = HTML::Sanitizer.new

        # Setup Fixer
        @fixer = Quasar::Fixer.new

        # Process each schedule
        @schedules.each do |movie|

          begin
            process_movie(movie)
          rescue
            Rails.logger.error("Failed to process movie when updating for cinema schedules. Attributes: #{movie.attributes.inspect}")
          end

        end

      end

      def process_movie(movie)

        # Clean and normalize title
        title = @sanitizer.sanitize(movie[:name], tags: [])
        info = @fixer.find_movie(title)

        # Initialize a new movie record
        fixed_title = @sanitizer.sanitize(info[:title], tags: [])
        movie_obj = Movie.find_or_initialize_by(title: fixed_title)

        # For new movies
        if movie_obj.new_record? 

          # Add the MTRCB rating
          unless movie[:rating].nil?
            movie_obj.mtrcb_rating = movie[:rating]
          end

          # Add the sources
          info[:sources].each do |source|
            add_movie_source(movie_obj, source)
          end

        end

        # Process our schedules
        movie[:schedules].each do |sked|

          # If this is a new movie, just add the schedules
          if movie_obj.new_record?
            add_schedule(movie_obj, sked)

          # If it already exists, check if the schedule exists
          # first before adding
          else
            unless Schedule.existing?(movie_obj, @cinema, sked[:time], sked[:cinema_name])
              add_schedule(movie_obj, sked)
            end
          end

        end

        movie_obj.save!

      end

      # Adds an external source reference to our movie model
      # source should be a hash of 'name' for the source name
      # and 'id' for the ID the source uses for the movie
      def add_movie_source(movie, source)
        movie.sources.build({
          name: source[:name],
          external_id: source[:id],
          url: source[:url]
        })
      end

      # Adds the schedule to our movie model
      def add_schedule(movie, sked)
        
        ticket_url = sked[:ticket_url] unless sked[:ticket_url].nil?
        price = sked[:price] unless sked[:price].nil?

        movie.schedules.build({
          cinema: @cinema,
          screening_time: sked[:time],
          format: sked[:format],
          ticket_url: ticket_url,
          ticket_price: price,
          room: sked[:cinema_name]
        })

      end

      # Logs a movie model's errors to our log file
      def log_movie_errors(movie)

        # Movie object errors
        unless movie.errors.empty?
          movie.errors.full_messages.each do |error|
            Rails.logger.warn("Failed to save movie (#{movie.attributes.inspect}: #{error}")
          end
        end

        # Schedule errors
        movie.schedules.each do |sked|
          unless sked.errors.empty?
            sked.errors.full_messages.each do |error|
              Rails.logger.warn("Failed to save schedule (#{sked.attributes.inspect}: #{error}")
            end
          end
        end

      end

  end
end