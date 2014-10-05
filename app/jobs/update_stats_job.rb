# Updates database statistics like the total row count
# and sends us an alert if we are reaching Heroku's
# 10,000 total rows limit.
#
# This job runs every 12:00 midnight.
class UpdateStatsJob
  include Sidekiq::Worker

  def perform

    # Postgresql only support.
    return unless ActiveRecord::Base.connection.instance_of? ActiveRecord::ConnectionAdapters::PostgreSQLAdapter

    conn = ActiveRecord::Base.connection
    res = conn.execute('SELECT SUM(n_live_tup) AS total FROM pg_stat_user_tables;')
    count = res.first['total'].to_i

    Rails.cache.write('db_count', count)

    Rails.logger.info("Successfully updated database stats. Total row count: #{count} rows")

  end

end