# Updates a movie's details like overview, posters, backdrop
class UpdateMovieJob
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  sidekiq_options throttle: { threshold: 5, period: 1.second, key: 'rt-api-client' }

  def perform(movie_id)

    movie_id = movie_id.to_i
    raise "Invalid Movie ID #{movie_id}" if movie_id <= 0

    movie = Movie.includes(:sources).find(movie_id)

    begin

      movie.find_sources!
    
      if movie.sources.count > 0
        movie.find_details!
        movie.find_trailer!
        movie.update_status
        movie.save!
        Rails.logger.info("UpdateMovieJob - Successfully updated movie \"#{movie.title}\".")
      else
        Rails.logger.error("UpdateMovieJob - Failed to update movie \"#{movie.title}\", no sources found.")
      end

    rescue Exceptions::QuotaReached => e
      # Handle quotas
      if e.service == 'RottenTomatoes'
        self.class.perform_in(5.seconds, movie_id)
      elsif e.service == 'Google'
        self.class.perform_in(12.hours, movie_id)
      else
        raise "Don\'t know when to reschedule job when quota for %s is reached.", % [e.service]
      end
    end

  end

end