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

    cinema = Cinema.find(cinema_id)
    fetcher = Quasar::SchedulesFetcher.new(cinema)
    fetcher.perform

    fetcher.new_movies.each do |movie|
      UpdateMovieJob.perform_async(movie.id)
    end

  end

end