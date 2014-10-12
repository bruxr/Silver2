require 'singleton'
module Scheduler

  # Dispatcher is responsible for building schedules,
  # updating the schedule list and telling Sidekiq
  # to run a job.
  #
  # Check the notes on scheduler.rb for more info
  #
  # Job format:
  # {
  #   job: job class
  #   next_run: next run time
  #   last_run: last run time
  #   last_status: status of last job run. can be "OK", "FAILED", "RETRY"
  #   execution_time: number of secs a job used
  # }
  class Manager
    include Singleton
    include Scheduler::Storage

    def initialize
      
    end

    def schedule(klass)
      klass.perform_in(klass.every)
    end

  end

end