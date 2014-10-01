# Caches TMDB configuration which are used in building
# backdrop and movie poster image URLs.
class CacheTmdbConfigJob
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { monthly.day_of_month(5, 10, 15, 20, 25, 30) }

  def perform

    tmdb = Quasar::WebServices::Tmdb.new(ENV['TMDB_API_KEY'])
    config = tmdb.get_configuration
    Rails.cache.write('tmdb:config', config, { expires_in: 30.days })

    Rails.logger.info("Successfully cached TMDB config.")

  end

end