# Updates database statistics like the total row count
# and sends us an alert if we are reaching Heroku's
# 10,000 total rows limit.
#
# This job runs every 12:00 midnight.
class UpdateStatsJob
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { daily.hour_of_day(0) }

  def perform

    count = 0

    count += Cinema.all.count
    count += Movie.all.count
    count += Schedule.all.count
    count += Source.all.count
    count += User.all.count

    conn = ActiveRecord::Base.connection
    res = conn.execute('SELECT COUNT(*) FROM schema_migrations')
    count += res.first.first.to_i

    Rails.cache.write('db_count', count)

    Rails.logger.info("Successfully updated database stats. Total row count: #{count} rows")

  end

end