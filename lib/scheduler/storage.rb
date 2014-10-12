module Scheduler::Storage

    JOBS_KEY = 'scheduler:jobs'
    QUEUE_KEY = 'scheduler:queued'

    def load_jobs
      Sidekiq.redis do |redis|

        @jobs = {}
        if redis.exists(JOBS_KEY)
          x = redis.hgetall(JOBS_KEY).flatten
          @jobs[x[0]] = JSON.parse(x[1])
        end

        @queued = {}
        if redis.exists(QUEUE_KEY)
          x = redis.hgetall(QUEUE_KEY).flatten
          @queued[x[0]] = x[1]
        end

      end
    end

    def save_jobs
      Sidekiq.redis do |redis|

        redis.del(JOBS_KEY)
        @jobs.each do |job, data|
          redis.hset(JOBS_KEY, job, data.to_json)
        end

        redis.del(QUEUE_KEY)
        @queued.each do |job, jid|
          redis.hset(QUEUE_KEY, job, jid)
        end

      end
    end

end