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
# DIFFERENCES:
# As far as I can tell, Discourse's Scheduler doesn't use Sidekiq's
# worker pool but instead uses it's own Runner class which just
# performs one job at a time.
#
# This scheduler aims to alleviate that by passing job execution
# to Sidekiq.
#
# POSSIBLE ISSUES:
# - This hasn't been tested with multiple Sidekiq processes.
# - Doesn't gracefully work if the Sidekiq server is suddenly
#   stopped then restarted.
# - Doesn't update with sidekiq. For example: a failed job
#   is marked as on "RETRY" in Scheduler but cancelling/deleting
#   it on Sidekiq will not update the status on Scheduler.
#
# KNOWN LIMITATIONS:
# - Doesn't support arguments to perform_async since the
#   manager just invokes perform_async directly and it only
#   checks for uniqueness by using the job/class name.
module Scheduler
end

require_dependency 'scheduler/manager'
require_dependency 'scheduler/schedulable'