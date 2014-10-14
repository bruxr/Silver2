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

    # Loads jobs in app/jobs and schedules them if they aren't scheduled yet.
    def load_jobs
      Dir["#{Rails.root}/app/jobs/*.rb"].each do |file|
        require_dependency file
      end
      ObjectSpace.each_object(Scheduler::Schedulable) do |klass|
        schedule(klass) unless scheduled?(klass)
      end
    end

    # Schedules a job for a run later
    def schedule(klass)
      klass.perform_at(klass.next_run)
    end

    # Returns TRUE if klass is already scheduled.
    # This is really expensive! So use only when you really
    # need to know if a klass is scheduled
    def scheduled?(klass)
      scheduled = false
      klass = klass.to_s
      Sidekiq::ScheduledSet.new.each do |j|
        scheduled = true if j.klass == klass
      end
      return scheduled if scheduled
      Sidekiq::Queue.new.each do |j|
        scheduled = true if j.klass == klass
      end
      return scheduled if scheduled
      Sidekiq::RetrySet.new.each do |j|
        scheduled = true if j.klass == klass
      end
      scheduled
    end

  end

end