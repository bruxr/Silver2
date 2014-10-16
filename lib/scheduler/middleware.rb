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
      Scheduler::Manager.instance.schedule(klass) if klass.is_a?(Scheduler::Schedulable)
    end

  end
end