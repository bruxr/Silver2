module Quasar
  module WebServices

    # Lightweight client to the OMDB API (http://www.omdbapi.com)
    class Omdb

      @@endpoint = 'http://www.omdbapi.com'

      # Searches the OMDB API given a movie title
      def find_title(title)

        resp = query({s: title})
        result = nil
        unless resp.nil?
          unless resp['Search'].nil?
            resp['Search'].each do |item|
              if item['Type'] == 'movie'
                result = {
                  title: item['Title'],
                  id: item['imdbID'],
                  url: "http://www.imdb.com/title/#{item['imdbID']}"
                }
                break
              end
            end
          end
        end

        result

      end

      # Generic query method. Just provide a params hash
      # and it'll take care of the rest :)
      #
      # Params reference: http://www.omdbapi.com/
      def query(data)

        data = data.to_query
        url = "#{@@endpoint}?#{data}"
        client = HTTParty.get(url)
        if client.code == 200
          resp = JSON.parse(client.body)
        else
          resp = nil
        end

      end

    end

  end
end