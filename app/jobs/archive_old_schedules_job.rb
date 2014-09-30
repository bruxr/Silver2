# Archives old schedules offsite so we can still be
# inside Heroku's 10k rows limit.
class ArchiveOldSchedulesJob
  include Sidekiq::Worker

  recurrence { daily.hour_of_day(0) }

  def perform()

    Schedule.archive_old_records

  end

  private

end