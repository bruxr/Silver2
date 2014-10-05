# Master job for updating incomplete and still active
# (still has future schedules) movies.
# Enqueues UpdateMovieJob's that will perform the update.
class UpdateIncompleteMoviesJob
  include Sidekiq::Worker

  def perform()

    movies = Movie.now_showing.incomplete.select('id').distinct.all
    movies.each do |movie|
      UpdateMovieJob.perform_async(movie.id)
    end

    Rails.logger.info("Successfully enqueued #{movies.count} UpdateMovieJob jobs.")

  end

end