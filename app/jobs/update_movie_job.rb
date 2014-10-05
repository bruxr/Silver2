# Updates a movie's details like overview, posters, backdrop
class UpdateMovieJob
  include Sidekiq::Worker

  sidekiq_options throttle: { threshold: 5, period: 1.second, key: 'rt-api-client' }

  def perform(movie_id)

    raise "Invalid Movie ID #{movie_id}" if movie_id <= 0

    movie = Movie.includes(:sources).find(movie_id)
    
    if movie.sources.count > 0
      movie.find_details
      movie.find_trailer
      movie.update_status
      movie.save
      Rails.logger.info("Successfully updated movie \"#{movie.title}\".")
    else
      Rails.logger.warn("Cannot update movie \"#{movie.title}\". No sources found.")
    end

  end

end