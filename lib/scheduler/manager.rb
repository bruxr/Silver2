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

    def initialize
      @jobs = {}
      @queued = {}
    end

    def register(job)
      @jobs[job.to_s] = {
        job: job,
        next_run: (Time.now + job.every).to_f
      } if @jobs[job.to_s].nil?
      puts "registered #{job.to_s} job, next run is #{Time.now + job.every}".green
    end

    def tick
      now = Time.now.to_f
      @jobs.each do |job_name, job|
        perform_job(job_name) if job[:next_run] <= now && !enqueued?(job_name)
      end
    end

    def perform_job(job)
      now = Time.now
      jid = @jobs[job][:job].perform_async
      @jobs[job][:jid] = jid
      @jobs[job][:last_run] = now
      @queued[job] = jid
      puts "enqueued #{job[:job].to_s} (#{jid})".green
    end

    def enqueued?(job)
      !@queued[job].nil?
    end

    # Only used by the server middleware to let the manager
    # know that a job has finished.
    def finished(job)
      now = Time.now
      @jobs[job][:last_status] = 'OK'
      @jobs[job][:execution_time] = now - @jobs[job][:last_run]
      @jobs[job][:next_run] = now + @jobs[job][:job].every
      @queued.delete(job)
      puts "#{job} finished.".green
    end

    # Only used by the server middleware to let the manager
    # know that a job is in the retry queue
    def retry(job)
      now = Time.now
      @jobs[job][:last_status] = 'RETRY'
      @jobs[job][:execution_time] = now - @jobs[job][:last_run]
      puts "#{job} failed".red
    end

  end

end