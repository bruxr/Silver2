module Quasar

  # MovieUpdater is responsible for grabbing movie info
  # from external web services.
  #
  # Instantiate with a movie model then invoke perform
  # to update that movie's info.
  class MovieUpdater

    # Stores them movie model and then creates a 
    # @sources hash with the source name as key
    # and external movie ID as values.
    def initialize(movie)
      @movie = movie

      @sources = {}
      @movie.sources.each do |source|
        @sources[source.name] = source.external_id
      end
    end

    def perform

      # Find details from sources.
      if !@sources['tmdb'].nil?
        update_from_tmdb(@sources['tmdb'])
      elsif !@sources['omdb'].nil?
        update_from_omdb(@sources['omdb'])
      else
        raise "No sources to use for \"#{@movie.title}\""
      end

      # Try to find a trailer
      begin
        tf = Quasar::TrailerFinder.new(ENV['G_CSE_ID'], ENV['G_API_KEY'])
        @movie.trailer = tf.find_trailer(@movie.title)

      # If we cannot find a trailer for this movie, log and then move on.
      rescue Quasar::Exceptions::NothingFound => e
        Rails.logger.warn("Failed to find a trailer for \"#{@movie.title}\"")
      end

      # Mark the movie as ready if all its required info is already set.
      keys = [:overview, :runtime, :poster, :trailer, :backdrop]
      @movie.status = 'ready'
      keys.each do |key|
        if @movie.public_send(key).nil?
          @movie.status = 'incomplete'
        end
      end

      # Save to the database
      @movie.save

    end

    private

      # Checks if the movie's details are in TMDB and uses those
      # to update the movie's info.
      def update_from_tmdb(movie_id)

        tmdb = Quasar::WebServices::Tmdb.new(ENV['TMDB_API_KEY'])
        result = tmdb.get_details(movie_id)
        unless result.nil?
          @movie.overview = result['overview']
          @movie.runtime = result['runtime'].to_i
          #genres: result['genres'].map{ |genre| genre.values }.flatten,
          @movie.poster = result['poster_path']
          #homepage: result['homepage'],
          #@movie.tagline = result['tagline'],
          @movie.backdrop = result['backdrop_path']
        end

      end

      # Checks if the movie's details are in OMDB and then uses those
      # to update the movie's information.
      def update_from_omdb(movie_id)

        omdb = Quasar::WebServices::Omdb.new
        result = omdb.get_details(movie_id)
        unless result.nil?
          @movie.overview = result['Plot']
          @movie.runtime = result['Runtime'].gsub('min', '') unless result['Runtime'].nil?
          #details[:genres] = result['Genre'].split(', ') unless result['Genre'].nil?
          @movie.poster = result['Poster']
        end

      end

  end

end