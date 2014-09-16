module Quasar
  module WebServices

    # Simple API for accessing Google Custom Search
    # Initialize with an engine ID (cx, cref) and
    # project API Key to use (key)
    class Google < Quasar::WebClient

      @@endpoint = 'https://www.googleapis.com/customsearch/v1'

      def initialize(engine_id, api_key)
        @engine_id = engine_id
        @api_key = api_key
      end

      # Performs a search query
      def search(query, params = {})

        defaults = {
          q: query,
          cx: @engine_id,
          key: @api_key
        }
        params = params.merge(defaults)
        response = get(@@endpoint, params)
        JSON.parse(response)

      end

    end

  end
end