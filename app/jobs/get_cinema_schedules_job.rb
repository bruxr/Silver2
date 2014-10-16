# Enqueues a GetSchedulesJob for every cinema that is active
# and has a scraper class.
# Runs every 6 am, every day.
class GetCinemaSchedulesJob
  include Sidekiq::Worker
  extend Scheduler::Schedulable

  every '9:00 am every day'

  def perform()

    cinemas = Cinema.is_active.has_scraper.select('id').all
    cinemas.all.each do |cinema|
      GetSchedulesJob.perform_async(cinema.id)
    end

    Rails.logger.info("Successfully enqueued #{cinemas.count} GetSchedulesJob.")

  end

end