module Quasar
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

      movies = get_movies @branch_code
      movies.each do |item|
        
        movie = {}
        movie[:name] = item['movie_name']
        movie[:schedules] = []

        screenings = get_screenings @branch_code, movie[:name]
        
        screenings.each do |cinema, schedules|
          schedules.each do |screening|
            sked = {}
            sked[:cinema_name] = screening['CinemaName']
            sked[:price] = screening['Price'].to_f
            sked[:time] = Time.zone.parse screening['StartTime']
            if screening['FilmFormat'] == 'F2D'
              sked[:format] = '2D'
            elsif screening['FilmFormat'] == 'F3D'
              sked[:format] = '3D'
            end
            sked[:ticket_url] = "http://smcinema.com/movies/buy-tickets/?mctkey=#{screening['MctKey']}"
            movie[:rating] = screening['MtrcbRating']
            movie[:schedules] << sked
          end
        end

        @schedules << movie

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

  end
end