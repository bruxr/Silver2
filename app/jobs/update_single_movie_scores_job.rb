# Updates a movie's scores/ratings from its external sources.
class UpdateSingleMovieScoresJob
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { daily.hour_of_day(6, 12, 18, 24) }

  def perform(movie_id)

    movie = Movie.includes(:sources).find(movie_id)
    movie.update_scores
    movie.save

    Rails.logger.info("Successfully updated scores of \"#{movie.title}\"")

  end

end