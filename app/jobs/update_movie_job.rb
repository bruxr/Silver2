# Updates a movie's details like overview, posters, backdrop
class UpdateMovieJob
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  sidekiq_options throttle: { threshold: 5, period: 1.second, key: 'rt-api-client' }

  def perform(movie_id)

    movie_id = movie_id.to_i
    raise "Invalid Movie ID #{movie_id}" if movie_id <= 0

    movie = Movie.includes(:sources).find(movie_id)
    movie.find_sources!
    
    if movie.sources.count > 0
      begin
        movie.find_details!
        movie.find_trailer!

      rescue Exceptions::QuotaReached => e
        self.class.perform_in(5.seconds, movie_id) # If we reach the quota, back off for 5 seconds.
      else
        movie.update_status
        movie.save
        Rails.logger.info("UpdateMovieJob - Successfully updated movie \"#{movie.title}\".")
      end
    else
      Rails.logger.error("UpdateMovieJob - Failed to update movie \"#{movie.title}\", no sources found.")
    end

  end

end