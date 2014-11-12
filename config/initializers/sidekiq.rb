require 'sidekiq-status'

Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add(Sidekiq::Status::ClientMiddleware)
  end
end

Sidekiq.configure_server do |config|
  require 'scheduler/scheduler'

  config.client_middleware do |chain|
    chain.add(Sidekiq::Status::ClientMiddleware)
  end

  config.server_middleware do |chain|
    chain.add(Sidekiq::Throttler, storage: :redis)
    chain.add(Scheduler::Middleware)
    chain.add(Sidekiq::Status::ServerMiddleware, expiration: 30.minutes)
  end

end

if Sidekiq.server?
  Scheduler::Manager.instance.load_jobs
end