module Scheduler
  class Middleware

    def call(worker, msg, queue)
      yield
    rescue Exception => e
      Scheduler::Manager.instance.retry(msg['class']) if msg['retry'] == true
      raise e
    else
      Scheduler::Manager.instance.finished(msg['class'])
    end

  end
end