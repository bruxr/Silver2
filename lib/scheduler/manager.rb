require 'singleton'
module Scheduler

  # Dispatcher is responsible for building schedules,
  # updating the schedule list and telling Sidekiq
  # to run a job.
  #
  # Check the notes on scheduler.rb for more info
  class Manager
    include Singleton

    def initialize
      @jobs = []
      @schedule = {}
    end

    def register(job)
      unless registered?(job)
        @jobs << job.to_s
        enqueue(job)
      end
    end

    def registered?(job)
      @jobs.include?(job)
    end

    def enqueue(job)
      @enqueued[job.to_s] = job.perform_at(job.next_run)
    end

    def tick
      ap @enqueued
      # Check for finished jobs and then check if they succeeded.
      # If they do, re enqueue them with the next run time.
      done_jobs.each do |job|
        enqueue(job['class']) if registered?(job)
      end
    end

    def done_jobs
      Sidekiq.redis do |redis|
        redis.zrange('schedule', 0, 1).each do |j|
          return JSON.parse(j) if j
        end
      end
    end

  end

end