# Enqueues a GetSchedulesJob for every cinema that is active
# and has a scraper class.
# Runs every 6 am, every day.
class GetCinemaSchedulesJob
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { daily.hour_of_day(6) }

  def perform()

    cinemas = Cinema.is_active.has_scraper.all
    cinemas.all.each do |cinema|
      scraper = "Quasar::Scrapers::#{cinema.fetcher}".constantize
      GetSchedulesJob.perform_async(cinema.id, scraper)
    end

    Rails.logger.info("Successfully enqueued #{cinemas.count} GetSchedulesJob.")

  end

end