# Silver was using Sidetiq for recurring jobs but recent versions
# of the gem doesn't work. Sidetiq's Web UI also doesn't display
# any scheduled jobs.
#
# I wrote Scheduler as a working replacement for Sidetiq and to
# address the ff issues as well:
# - monitor job execution time
# - whether the job failed or succeeded
# - how many times the job has executed
#
# This is heavily inspired by Discourse's Scheduler:
# https://github.com/discourse/discourse/tree/master/lib/scheduler
#
# POSSIBLE ISSUES:
# - This hasn't been tested with multiple Sidekiq processes.
# - Doesn't gracefully work if the Sidekiq server is suddenly
#   stopped then restarted.
module Scheduler
end

require_dependency 'scheduler/manager'
require_dependency 'scheduler/schedulable'