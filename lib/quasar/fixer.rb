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

        result = {
          title: nil,
          sources: []
        }

        # Search TMDB
        tmdb = Quasar::WebServices::Tmdb.new(ENV['TMDB_API_KEY'])
        tmdb_res = tmdb.find_title(title)
        unless tmdb_res.nil?
          result[:title] = tmdb_res[:title]
          result[:sources] << {
            name: 'tmdb',
            id: tmdb_res[:id],
            url: tmdb_res[:url]
          }
        end

        # and Rotten Tomatoes
        rt = Quasar::WebServices::RottenTomatoes.new(ENV['RT_API_KEY'])
        rt_res = rt.find_title(title)
        unless rt_res.nil?
          result[:title] = rt_res[:title] if result[:title].nil?
          result[:sources] << {
            name: 'rt',
            id: rt_res[:id],
            url: rt_res[:url]
          }
        end

        # and OMDB
        omdb = Quasar::WebServices::Omdb.new
        omdb_res = omdb.find_title(title)
        unless omdb_res.nil?
          result[:title] = omdb_res[:title] if result[:title].nil?
          result[:sources] << {
            name: 'omdb',
            id: omdb_res[:id],
            url: omdb_res[:url]
          }
        end

        # then Metacritic.
        # try with the actual title first, if it exists
        # since the services up top are more accurate.
        metacritic = Quasar::WebServices::Metacritic.new(ENV['MASHAPE_API_KEY'])
        unless result[:title].nil?
          mc_res = metacritic.find_title(result[:title])
          unless mc_res.nil?
            result[:sources] << {
              name: 'metacritic',
              id: mc_res[:id],
              url: mc_res[:url]
            }
          end
        else
          mc_res = metacritic.find_title(title)
          unless mc_res.nil?
            result[:title] = mc_res[:title]
            result[:sources] << {
              name: 'metacritic',
              id: mc_res[:id],
              url: mc_res[:url]
            }
          end
        end

        result

      end

    end

    # Attempts to find extended movie information like
    # plot, runtime, cast etc.
    #
    # Pass in an array of sources hash e.g.
    # [
    #   { name: 'metacritic', id: "The Amazing Spider Man" },
    #   { name: 'omdb', id: 'tt12345' }
    # ]
    def get_details(sources)

      details = nil

      # Convert our array to a hash
      if sources.instance_of?(Array)
        srcs = {}
        sources.each do |h|
          srcs[h[:name].to_sym] = h[:id]
        end
      end

      # Check if we have TMDB first and we can get details from it
      if !srcs[:tmdb].nil?
        tmdb = Quasar::WebServices::Tmdb.new(ENV['TMDB_API_KEY'])
        result = tmdb.get_details(srcs[:tmdb])
        unless result.nil?
          details = {
            overview: result['overview'],
            runtime: result['runtime'].to_i,
            genres: result['genres'].map{ |genre| genre.values }.flatten,
            poster: tmdb.image(result['poster_path']),
            homepage: result['homepage'],
            tagline: result['tagline'],
            backdrop: tmdb.image(result['backdrop_path'])
          }
        end
      # Otherwise, use OMDB
      elsif !srcs[:omdb].nil?
        omdb = Quasar::WebServices::Omdb.new
        result = omdb.get_details(srcs[:omdb])
        unless result.nil?
          details = {}
          details[:overview] = result['Plot']
          details[:runtime] = result['Runtime'].gsub('min', '') unless result['Runtime'].nil?
          details[:genres] = result['Genre'].split(', ') unless result['Genre'].nil?
          details[:poster] = result['Poster']
        end
      end

      details

    end

    # Finds a high resolution trailer for title
    def find_trailer(title)

      

    end

  end

end