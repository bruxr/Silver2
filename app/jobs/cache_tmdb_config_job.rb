# Caches TMDB configuration which are used in building
# backdrop and movie poster image URLs.
class CacheTmdbConfigJob
  include Sidekiq::Worker
  extend Scheduler::Schedulable

  every 1.day

  def perform

    Tmdb.new.cache_configuration
    Rails.logger.info("Successfully cached TMDB config.")

  end

end