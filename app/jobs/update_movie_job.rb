# Updates a movie's details like overview, posters, backdrop
class UpdateMovieJob
  include Sidekiq::Worker

  def perform(movie_id)

    movie = Movie.include(:sources).find(movie_id)
    
    if movie.sources.count > 0
      updater = Quasar::MovieUpdater.new(movie)
      updater.perform
      Rails.logger.info("Successfully updated movie \"#{movie.title}\".")
    else
      Rails.logger.warn("Cannot update movie \"#{movie.title}\". No sources found.")
    end

  end

end