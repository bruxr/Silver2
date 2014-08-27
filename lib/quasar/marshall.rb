module Quasar
  
  # Quasar Marshalls convert the schedule array provided
  # by fetchers into actual models and then recorded
  # into the database.
  class Marshall

    attr_reader :schedules

    # Initialization/constructor.
    # Sets the source of schedules and the client class.
    # Pass in a cinema model to start.
    def initialize(cinema)
      @cinema = cinema
      @klass = "Quasar::Clients::#{cinema.fetcher}".constantize
    end

    # Performs the processing of schedules
    # and recording to the database.
    def perform
      
      @fetcher = @klass.new
      @schedules = @fetcher.get_schedules

      process_movies

    end

    private

      # Processes the movie titles, performs sanity checks
      # and creates new records if they don't exist yet.
      def process_movies

        # Setup sanitizer
        require 'html/sanitizer'
        sanitizer = HTML::Sanitizer.new

        # Setup Fixer
        fixer = Quasar::Fixer.new

        @schedules.each do |movie|

          # Clean and normalize title
          title = sanitizer.sanitize(movie[:name], tags: [])
          info = fixer.find_movie(title)

          # Initialize a new movie record
          fixed_title = sanitizer.sanitize(info[:title], tags: [])
          movie_obj = Movie.find_or_initialize_by(title: fixed_title)

          # Add the MTRCB rating if this is a new record
          if movie_obj.new_record? and ! movie[:rating].nil?
            movie_obj.mtrcb_rating = movie[:rating]
          end

          # Add our schedules
          movie[:schedules].each do |sked|
            ticket_url = sked[:ticket_url] unless sked[:ticket_url].nil?
            price = sked[:price] unless sked[:price].nil?
            movie_obj.schedules.build({
              cinema: @cinema,
              screening_time: sked[:time],
              format: sked[:format],
              ticket_url: ticket_url,
              ticket_price: price
            })
          end

          movie_obj.save

        end

      end

  end
end