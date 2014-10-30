# Updates a movie's scores/ratings from its external sources.
class UpdateSingleMovieScoresJob
  include Sidekiq::Worker

  sidekiq_options throttle: { threshold: 5, period: 1.second, key: 'rt-api-client' }

  def perform(movie_id)

    movie = Movie.includes(:sources).find(movie_id)
    begin
      movie.update_scores!
      movie.save
    rescue Exceptions::QuotaReached => e
      self.class.perform_in(5.seconds, movie_id) # If we reach the quota, back off for 5 seconds.
    else
      movie.save
      Rails.logger.info("Successfully updated scores of \"#{movie.title}\"")
    end

  end

end