module Quasar
  module Clients

    # The base class of all Quasar Fetchers for SM Cinemas.
    # Provides common methods for accessing the
    # cinemas' AJAX endpoints, automatically converting
    # responses to JSON.
    # 
    # TODO: find a way on how to buy tickets b/c sm requires
    # a popup login to buy tickets.
    class SmFetcher < Fetcher

      # Returns an array of screening times for
      # movies available to a branch
      def get_schedules()

        @schedules = []

        # Create a MTRCB ratings translation hash
        # because SM doesn't use the complete words.
        ratings = {}
        ratings['G'] = 'G'
        ratings['PG'] = 'PG'
        ratings['R13'] = 'R-13'
        ratings['R16'] = 'R-16'
        ratings['R18'] = 'R-18'

        movies = get_movies @branch_code

        # Check if we have an error first
        if movies[0] == 'error'
          raise Quasar::ScrapingError("SM Cinema API returned an error: #{movies[1]}")
        else
          process_movies(movies)
        end

        return @schedules

      end

      protected

        # Returns the movies available under a branch
        # (e.g. SMCD for SM City Davao)
        def get_movies(branch_code)

          data = {
            method: 'listMovies',
            branch_code: branch_code
          }
          resp = post 'http://smcinema.com/ajaxMovies.php', data
          JSON.parse resp

        end

        # Returns the screening times for a movie.
        # Provide the branch code & movie name from get_movies().
        def get_screenings(branch_code, movie_name)

          data = {
            method: 'listScreeningTime',
            branch_code: branch_code,
            movie_name: movie_name
          }
          resp = post 'http://smcinema.com/ajaxMovies.php', data
          JSON.parse resp

        end

        # Processes each movie object returned from the API,
        # reading the items (e.g. title, format, price) we needed.
        def process_movies(movies)

          movies.each do |item|
          
            movie = {}
            movie[:name] = item['movie_name']
            movie[:schedules] = []

            screenings = get_screenings @branch_code, movie[:name]
            
            screenings.each do |cinema, schedules|
              schedules.each do |screening|
                
                sked = {}
                
                # Translate SM's custom ratings to the official MTRCB ones
                # Raise a ignorable Exception if they use an unknown one. 
                if ! screening['MtrcbRating'].empty?
                  if ratings[screening['MtrcbRating']].nil? 
                    raise Exception.new("SM Fetcher: Unknown MTRCB rating #{screening['MtrcbRating']}, skipping it instead.")
                  else
                    movie[:rating] = ratings[screening['MtrcbRating']]
                  end
                end

                # Translate Film formats
                if screening['FilmFormat'] == 'F2D'
                  sked[:format] = '2D'
                elsif screening['FilmFormat'] == 'F3D'
                  sked[:format] = '3D'
                elsif screening['FilmFormat'] == 'F3D' and screening['CinemaType'] == 'IMAX'
                  sked[:format] = 'IMAX'
                end

                # Add the rest of the schedule info
                sked[:cinema_name] = screening['CinemaName']
                sked[:price] = screening['Price'].to_f
                sked[:time] = Time.zone.parse screening['StartTime']
                sked[:ticket_url] = "http://smcinema.com/movies/buy-tickets/?mctkey=#{screening['MctKey']}"
                movie[:schedules] << sked

              end
            end

            @schedules << movie

          end

        end

    end

  end
end