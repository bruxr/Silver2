class TestJob
  include Sidekiq::Worker

  def perform
    Rails.logger.info("hello world!")
  end

end