# Updates a movie's details like overview, posters, backdrop
class UpdateMovieJob
  include Sidekiq::Worker

  def perform(movie_id)

    raise "Invalid Movie ID #{movie_id}" if movie_id <= 0

    movie = Movie.includes(:sources).find(movie_id)
    
    if movie.sources.count > 0
      movie.find_details
      movie.find_trailer
      movie.save
      Rails.logger.info("Successfully updated movie \"#{movie.title}\".")
    else
      Rails.logger.warn("Cannot update movie \"#{movie.title}\". No sources found.")
    end

  end

end