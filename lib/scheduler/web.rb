require 'sidekiq/web'

module Scheduler
  module Web

    VIEWS = File.expand_path('views', File.dirname(__FILE__))

    def self.registered(app)

      app.get('/scheduler') do
        @jobs = Scheduler::Manager.instance.jobs
        ap @jobs
        erb(File.read(File.join(VIEWS, 'scheduler.erb')))
      end

    end

  end
end

Sidekiq::Web.register(Scheduler::Web)
Sidekiq::Web.tabs["Scheduler"] = "scheduler"