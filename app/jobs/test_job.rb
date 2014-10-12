class TestJob
  include Sidekiq::Worker
  extend Scheduler::Schedulable

  every 1.minute

  def perform
    Rails.logger.info("hello world!")
  end

end