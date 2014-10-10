Sidekiq.configure_server do |config|
  require 'scheduler/scheduler'

  config.server_middleware do |chain|
    chain.add(Sidekiq::Throttler, storage: :redis)
  end

end

if Sidekiq.server?
  
  # Let the thread party start!
  manager = Scheduler::Manager.instance
  Thread.new do
    while true
      begin
        manager.tick
      rescue => err
        Rails.logger.error("#{err.message}") # Eew, log then continue the party
      end
      sleep 10
    end
  end

end