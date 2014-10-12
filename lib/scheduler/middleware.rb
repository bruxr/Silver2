# This Sidekiq server middleware schedules again
# recurring jobs.
module Scheduler
  class Middleware

    def call(worker, msg, queue)
      yield
    rescue Exception => e
      raise e
    else
      klass = msg['class'].constantize
      if klass.is_a? Scheduler::Schedulable
        klass.perform_in(klass.every)
      end
    end

  end
end