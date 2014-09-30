# Master job for updating incomplete and still active
# (still has future schedules) movies.
# Enqueues UpdateMovieJob's that will perform the update.
class UpdateIncompleteMoviesJob
  include Sidekiq::Worker

  recurrence { daily.hour_of_day(12, 24) }

  def perform()

    movies = Movie.now_showing.incomplete.select('id').all
    movies.each do |movie|
      UpdateMovieJob.perform_async(movie.id)
    end

  end

end