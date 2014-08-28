module Quasar
  module WebServices

    # Lightweight client to The Movie DB API.
    # Initialize with an API key, then invoke
    # get() with the method name and the params
    # you need. Tmdb will automatically add
    # the API key.
    class Tmdb

      def initialize(api_key)
        @api_key = api_key
      end

      # Builds image URLs for backdrops & posters.
      def image(image, size = 'original')

        "https://image.tmdb.org/t/p/#{size}#{image}"

      end

      # Convenience method for searching TMDB for
      # a movie title, returns TMDB's movie title
      # ID and URL or nil if nothing is returned.
      def find_title(title)
        
        data = { query: title }

        resp = get('/search/movie', data)
        unless resp.nil?
          unless resp['results'].empty?
            res = {
              id: resp['results'][0]['id'].to_i,
              title: resp['results'][0]['title'],
              url: "https://www.themoviedb.org/movie/#{resp['results'][0]['id']}"
            }
          end
        end

      end

      # Convenience method for grabbing details
      # for a specific movie using the given
      # movie ID.
      def get_details(id)

        get("/movie/#{id}")

      end

      # Accesses TMDB's API. Pass the method
      # with a leading forward slash (e.g. /job/list)
      # then a hash of params if needed.
      # I'll add the API Key automatically.
      def get(method, params = nil)

        query(method, params)
        if @last_client.code == 200
          return @last_response
        end

      end

      # Performs the same as get() but raises
      # an exception if TMDB returned an HTTP
      # status code other than 200.
      def get!(method, params = nil)

        query(method, params)
        if @last_client.code == 200
          return @last_response
        else
          raise "TMDB API Error (HTTP #{@last_client.status}) - @last_response['status_message'] (Code @last_response['status_code'])"
        end

      end

      private

        # Common query method used by get and get! to
        # access the TMDB API.
        def query(method, params = nil)

          endpoint = 'http://api.themoviedb.org/3'
          params = {} if params.nil?

          params[:api_key] = @api_key
          url = "#{endpoint}#{method}?".concat(params.to_query)

          @last_client = HTTParty.get(url)
          @last_response = JSON.parse(@last_client.body)

        end

    end

  end
end