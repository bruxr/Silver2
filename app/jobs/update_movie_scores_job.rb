# Updates Movie scores/ratings by enqueuing UpdateSingleMovieScores jobs
# for every "now showing" movies.
# Runs every 6 hours.
class UpdateMovieScoresJob
  include Sidekiq::Worker
  extend Scheduler::Schedulable

  every 6.hours

  def perform

    movies = Movie.now_showing.select('id').distinct.all
    count = 0
    movies.each do |movie|
      UpdateSingleMovieScoresJob.perform_async(movie.id)
      count += 0
    end

    Rails.logger.info("Enqueueing #{count} UpdateSingleMovieScoresJob for updating scores/ratings.")

  end

end