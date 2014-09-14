module Quasar

  # MovieUpdater is responsible for grabbing movie info
  # from external web services.
  #
  # Instantiate with a movie model then invoke perform
  # to update that movie's info.
  class MovieUpdater

    def initialize(movie)
      @movie = movie
    end

    def perform

      sources = []
      @movie.sources.each do |src|
        sources << {
          name: src.name,
          id: src.external_id
        }
      end

      fixer = Quasar::Fixer.new
      details = fixer.get_details(sources)

      # Add the trailer
      tf = Quasar::TrailerFinder.new(ENV['G_CSE_ID'], ENV['G_API_KEY'])
      details[:trailer] = tf.find_trailer(@movie.title)

      # Update the model if we have info,
      # otherwise log a warning.
      keys = [:overview, :runtime, :poster, :trailer, :backdrop]
      unless details.nil?

        # Save each detail, skipping if it is already set.
        keys.each do |key|
          if !details[key].nil? && @movie.public_send(key).nil?
            @movie.public_send("#{key}=", details[key])
          end
        end

        # Mark the movie as ready if all its info is set
        # otherwise it's incomplete.
        @movie.status = 'ready'
        keys.each do |key|
          if @movie.public_send(key).nil?
            @movie.status = 'incomplete'
          end
        end

        @movie.save

      else
        Rails.logger.warn("Movie Update: Failed to find information about \"#{@movie.title}\"")
      end

    end

  end

end