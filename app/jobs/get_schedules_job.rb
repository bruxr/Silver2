# Grabs cinema schedules using our web spiders
# and then creates schedules & movies (if it doesn't exist)
# for every record read from the websites.
#
# This will also enqueue a UpdateMovie job when we
# encounter a new movie.
class GetSchedulesJob
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { daily.hour_of_day(6) }

  # Crawls and processes the records we read from
  # the cinema's website.
  def perform(cinema_id, scraper)

    @cinema_id = cinema_id
    @scraper = scraper

    # Start crawling and then process the records
    @schedules = @spider.new.get_schedules
    process_movies

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
        process_movie(movie)
      end

    end

    def process_movie(movie)

      # Clean and normalize title
      title = @sanitizer.sanitize(movie[:name], tags: [])
      info = @fixer.find_movie(title)

      # If we can't find the actual title, use the original one.
      if info[:title].nil?
        info = {
          title: title,
          sources: []
        }
      end

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

end