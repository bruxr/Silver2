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
      @jobs = {}
      @queued = {}
      load_jobs
    end

    def register(job)
      klass = job.to_s
      @jobs[klass] = {
        job: klass,
        every: job.every,
        next_run: (Time.now + job.every).to_f
      } if @jobs[job.to_s].nil?
      save_jobs
      puts "registered #{job.to_s} job, next run is #{Time.now + job.every}".green
    end

    def tick
      now = Time.now.to_f
      @jobs.each do |job_name, job|
        ap job_name
        ap job
        ap "#{job_name} is queued" if enqueued?(job_name)
        perform_job(job_name) if job[:next_run] <= now && !enqueued?(job_name)
      end
    end

    def perform_job(job)
      ap "performing #{job}"
      now = Time.now
      jid = @jobs[job][:job].constantize.perform_async
      @jobs[job][:jid] = jid
      @jobs[job][:last_run] = now
      @queued[job] = jid
      save_jobs
      puts "enqueued #{job[:job].to_s} (#{jid})".green
    end

    def enqueued?(job)
      !@queued[job].nil?
    end

    # Only used by the server middleware to let the manager
    # know that a job has finished.
    def finished(job)
      update_job(job, 'OK')
      puts "#{job} finished.".green
    end

    # Only used by the server middleware to let the manager
    # know that a job is in the retry queue
    def retry(job)
      update_job(job, 'RETRY')
      puts "#{job} failed".red
    end

    def update_job(job, status)
      now = Time.now
      @jobs[job][:last_status] = status
      @jobs[job][:execution_time] = now - @jobs[job][:last_run]

      if status == 'OK'
        @jobs[job][:next_run] = now + @jobs[job][:job].constantize.every
        @queued.delete(job)
      end
      save_jobs
    end

  end

end