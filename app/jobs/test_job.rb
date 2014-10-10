class TestJob
  include Sidekiq::Worker
  extend Scheduler::Schedulable

  every 1.hour

  def perform
    Rails.logger.info("hello world!")
  end

end