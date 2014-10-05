# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

every 6.hours do
  runner 'UpdateMovieScoresJob.perform_async'
end

every 12.hours do
  runner 'UpdateIncompleteMoviesJob.perform_async'
end

every 1.day, at: '6:00 am' do
  runner 'GetCinemaSchedulesJob.perform_async'
end

every 1.day, at: '11:59 pm' do
  runner 'ArchiveOldSchedulesJob.perform_async'
end

every 5.days at: '11:59 pm' do
  runner 'CacheTmdbConfigJob.perform_async'
  runner 'UpdateStatsJob.perform_async'
end