require 'scheduler/schedulable'

# Caches TMDB configuration which are used in building
# backdrop and movie poster image URLs.
class CacheTmdbConfigJob
  include Sidekiq::Worker
  extend Scheduler::Schedulable

  every 'midnight'

  def perform

    Tmdb.new.cache_configuration
    Rails.logger.info("Successfully cached TMDB config.")

  end

end