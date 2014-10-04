# Updates Movie scores/ratings by enqueuing UpdateSingleMovieScores jobs
# for every "now showing" movies.
# Runs every 6 hours.
class UpdateMovieScoresJob
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { daily.hour_of_day(6, 12, 18, 24) }

  def perform

    movies = Movie.now_showing.select('id').all
    count = 0
    movies.each do |movie|
      UpdateSingleMovieScoresJob.perform_async(movie.id)
      count += 0
    end

    Rails.logger.info("Enqueueing #{count} UpdateSingleMovieScoresJob for updating scores/ratings.")

  end

end