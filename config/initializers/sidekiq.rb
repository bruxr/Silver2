Sidekiq.configure_server do |config|
  require 'scheduler/scheduler'

  config.server_middleware do |chain|
    chain.add(Sidekiq::Throttler, storage: :redis)
    chain.add(Scheduler::Middleware)
  end

end

if Sidekiq.server?
  Scheduler::Manager.instance.load_jobs
end