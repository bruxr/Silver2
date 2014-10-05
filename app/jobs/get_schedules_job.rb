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
    new_movies = cinema.schedules.fetch_new

    new_movies.each do |movie|
      UpdateMovieJob.perform_async(movie.id)
      UpdateSingleMovieScoresJob.perform_async(movie.id)
    end

    cinema.save

    Rails.logger.info("Successfully fetched new schedules for #{cinema.name}.")

  end

end