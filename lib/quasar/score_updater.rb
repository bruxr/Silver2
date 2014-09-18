module Quasar

  # ScoreUpdater is responsible for updating
  # a movie's scores & ratings using data
  # from critic websites like Rotten Tomatoes,
  # IMDB & Metacritic.
  class ScoreUpdater

    def initialize(movie)
      @movie = movie
    end

    def perform

      total = 0
      scores = 0

      @movie.sources.each do |source|
        
        case source.name
          when 'metacritic'
            service = Quasar::WebServices::Metacritic.new(ENV['MASHAPE_API_KEY'])
          when 'omdb'
            service = Quasar::WebServices::Omdb.new
          when 'rotten_tomatoes'
          when 'rt'
            service = Quasar::WebServices::RottenTomatoes.new(ENV['RT_API_KEY'])
          when 'tmdb'
            service = Quasar::WebServices::Tmdb.new(ENV['TMDB_API_KEY'])
          else
            raise "Cannot update scores for an unknown web service: #{source.name}."
        end

        unless service.nil?
          source.score = service.get_score(source.external_id)
          total += source.score
          scores += 1
        end

      end
      
      @movie.aggregate_score = total / scores
      @movie.save

    end

  end

end