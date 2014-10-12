class FailingJob
  include Sidekiq::Worker
  extend Scheduler::Schedulable

  every 1.minute

  def perform
    raise "I just fail at doing jobs :("
  end
end