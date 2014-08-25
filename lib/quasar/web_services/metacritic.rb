module Quasar
  module WebServices

    # Metacritic API Client through the Unofficial API in Mashape
    # https://www.mashape.com/byroredux/metacritic
    #
    # Instantiate with a Mashape API Key
    # then invoke the necessary methods.
    class Metacritic

      @@endpoint = 'https://byroredux-metacritic.p.mashape.com'

      def initialize(api_key)
        @api_key = api_key
      end

      # Searches the API for a movie that matches the
      # provided title.
      # Returns a hash of the movie's ID (also the title XD) and title
      def find_title(title)

        data = {
          max_pages: 1,
          title: title
        }
        resp = query('/search/movie', data)
        result = nil
        unless resp.nil?
          if resp['count'] > 0
            result = {
              id: resp['results'][0]['name'],
              title: resp['results'][0]['name']
            }
          end
        end

        result

      end

      # Fetches movie details using it's title.
      # Take note that metacritic doesn't expose an API
      # so we're just using the movie title as ID :)
      #
      # Important: Use the title returned by find_title() 
      # it's the only 100% sure identifier that will match.
      def get_details(id)

        data = {
          title: id
        }
        resp = query('/find/movie', data)
        unless resp.nil?
          result = resp['result']
          # Add an ID & title to match other web services
          result[:id] = result['name']
          result[:title] = result['name']
        else
          result = nil
        end

        result

      end

      # Generic API querying method.
      # Provide the method with the leading forward slash
      # and parameters if necessary.
      #
      # API key will be added to the headers automatically.
      def query(method, data = nil)

        data = {} if data.nil?
        options = {
          body: data,
          headers: {
            'X-Mashape-Key' => @api_key
          }
        }
        url = "#{@@endpoint}#{method}"
        client = HTTParty.post(url, options)
        if client.code == 200
          result = JSON.parse(client.body)
        else
          result = nil
        end

        result

      end

    end

  end
end