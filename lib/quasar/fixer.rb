module Quasar
  
  # Fixer is responsible for "normalizing" movie titles
  # by using the correct movie title using external
  # movie databases and collecting information about
  # them.
  #
  # Instantiate and then invoke the methods needed
  # when needing movie information.
  class Fixer

    # Searches TMDB, Rotten Tomatoes, OMDB and Metacritic
    # for the correct movie title (in that order)
    # IDs specific for each web service are also included
    # for future use.
    def find_movie(title)

      cache_key = "fixer:ids:#{title.parameterize}"

      # Check cache if we already have searched for this title
      result = Rails.cache.fetch(cache_key) do

        result = {}

        # Search TMDB
        tmdb = Quasar::WebServices::Tmdb.new(ENV['TMDB_API_KEY'])
        tmdb_res = tmdb.find_title(title)
        unless tmdb_res.nil?
          result[:title] = tmdb_res[:title]
          result[:tmdb_id] = tmdb_res[:id]
        end

        # and Rotten Tomatoes
        rt = Quasar::WebServices::RottenTomatoes.new(ENV['RT_API_KEY'])
        rt_res = rt.find_title(title)
        unless rt_res.nil?
          result[:title] = rt_res[:title] if result[:title].nil?
          result[:rt_id] = rt_res[:id]
        end

        # and OMDB
        omdb = Quasar::WebServices::Omdb.new
        omdb_res = omdb.find_title(title)
        unless omdb_res.nil?
          result[:title] = omdb_res[:title] if result[:title].nil?
          result[:omdb_id] = omdb_res[:id]
        end

        # then Metacritic.
        # try with the actual title first, if it exists
        # since the services up top are more accurate.
        metacritic = Quasar::WebServices::Metacritic.new(ENV['MASHAPE_API_KEY'])
        unless result[:title].nil?
          mc_res = metacritic.get_details(result[:title])
          unless mc_res.nil?
            result[:metacritic_id] = mc_res[:id]
          end
        else
          mc_res = metacritic.find_title(title)
          unless mc_res.nil?
            result[:title] = mc_res[:title] if result[:title].nil?
            result[:metacritic_id] = mc_res[:id]
          end
        end

        result

      end

    end

    # Grabs extended movie details from TMDB.
    # Provide a TMDB movie ID to return a hash of
    # movie information
    def get_details(movie_id)

      cache_key = "movie_details:#{movie_id}"

      unless Rails.cache.exist?(cache_key)
        data = {language: 'en'}
        details = @tmdb.get("/movie/#{movie_id}", data)

        unless details.nil?
          Rails.cache.write(cache_key, details)
          details
        else
          raise Exception.new("Quasar Fixer Error: Failed to get details for movie with ID #{movie_id}")
        end
      else
        details = Rails.cache.read(cache_key)
      end

    end

  end

end