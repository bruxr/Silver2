class FailingJob
  include Sidekiq::Worker

  def perform
    raise "I just fail at doing jobs :("
  end
end