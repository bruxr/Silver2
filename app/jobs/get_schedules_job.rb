# Grabs cinema schedules using our web spiders
# and then creates schedules & movies (if it doesn't exist)
# for every record read from the websites.
#
# This will also enqueue a UpdateMovie & UpdateMovieScores job when we
# encounter a new movie.
class GetSchedulesJob
  include Sidekiq::Worker

  # Crawls and processes the records we read from
  # the cinema's website.
  def perform(cinema_id)

    raise "Invalid Cinema ID: #{cinema_id}" if cinema_id <= 0

    cinema = Cinema.find(cinema_id)
    movies = cinema.scraper.schedules
    
    # Process scraped movies
    movies.each do |movie|
      
      title = Movie.fix_title(movie[:name])
      
      # Try to add the movie.
      # If it fails, then use the existing movie.
      new_record = true
      begin
        m = Movie.new(title: title, mtrcb_rating: movie[:rating])
        m.save!
      rescue 
        Rails.logger.warn("GetSchedulesJob: #{title} already exists in the database, using that instead.")
        m = Movie.find_by(title: movie[:name])
        new_record = false
      end
      
      # Add schedules to our movie
      movie[:schedules].each do |sked|
        unless Schedule.existing?(m, cinema, sked[:time], sked[:room])
          s = Schedule.new
          s.cinema_id = cinema_id
          s.screening_time = sked[:time]
          s.format = sked[:format]
          s.ticket_url = sked[:ticket_url]
          s.ticket_price = sked[:price]
          s.room = sked[:cinema_name]
          m.schedules << s
        end
      end
      
      m.save!
      
      # If this is a new movie record, add jobs that update
      # the movie's information.
      if new_record
        UpdateMovieJob.perform_async(movie.id)
        UpdateSingleMovieScoresJob.perform_async(movie.id)
      end
      
    end
    
    Rails.logger.info("Successfully fetched new schedules for #{cinema.name}.")

  end

end