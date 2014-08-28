module Quasar
  module WebServices

    # Rotten Tomatoes API Client
    # Initialize with an API Key then invoke
    # the methods you need.
    #
    # query() is also available as a generic
    # API access method.
    class RottenTomatoes

      @@endpoint = 'http://api.rottentomatoes.com/api/public/v1.0'

      def initialize(api_key)
        @api_key = api_key
      end

      # Searches the Rotten Tomatoes API
      # for a movie title.
      # Returns the title and its ID.
      def find_title(title)

        resp = query('/movies', {q: title, page_limit: 1, page: 1})
        unless resp.nil? 
          if resp['total'] > 0
            result = {
              title: resp['movies'][0]['title'],
              id: resp['movies'][0]['id'].to_i,
              url: resp['movies'][0]['links']['alternate']
            }
          else
            result = nil
          end
        else
          result = nil
        end

        result

      end

      # Returns the details for a movie
      # when provided with a movie ID.
      def get_details(id)
        result = query("/movies/#{id}")
      end

      # Returns the movie's rating in Rotten Tomatoes.
      # Set actual to TRUE to return the 0-100 score
      # instead of converted 0-10.
      # Take note that this combines both the critics
      # and the audience score.
      def get_score(id, audiences = false)

        details = get_details(id)

        # If we got an error, end early.
        if details.nil?
          nil
        else
          critics = details['ratings']['critics_score'].to_f / 10
          audience = details['ratings']['audience_score'].to_f / 10
          (critics + audience) / 2
        end

      end

      # Generic API querying method.
      # Provide the method (with leading forward-slash)
      # and corresponding parameters to acccess the API. 
      # format (JSON only) and API will be added automatically.
      #
      # Escape strings when needed!
      #
      # Example:
      # query('/movies', {q: 'iron+man'}) for movie search
      # query('/movies/714976247') for a specific movie
      def query(method, data = nil)

        data = {} if data.nil?
        data['apikey'] = @api_key
        data_str = data.to_query

        url = "#{@@endpoint}#{method}.json?#{data_str}"
        client = HTTParty.get(url)
        if client.code == 200
          resp = JSON.parse(client.body)
        else
          nil
        end

      end

    end

  end
end