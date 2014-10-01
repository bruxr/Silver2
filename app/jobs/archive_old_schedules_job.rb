# Archives old schedules offsite so we can still be
# inside Heroku's 10k rows limit.
class ArchiveOldSchedulesJob
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { daily.hour_of_day(0) }

  def perform()

    old_skeds = Schedule.archive_old_records
    Rails.logger.info("Successfully archived #{old_skeds} old schedules.")

  end

end