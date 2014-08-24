module Quasar
  # The base class for all Quasar fetchers/scrapers/accessors.
  # Provides get & post methods for accessing websites
  # and returns the unmodified response string.
  #
  # TODO: add support for custom headers
  class Fetcher

    attr_reader :schedules

    # Setups an empty array as schedules
    def initialize
      @schedules = []
    end

    # Sends a GET request to a URL
    def get(url, data = {}, headers = {})

      url << '?' << data.to_query unless data.empty?
      
      @client = HTTParty.get(url)
      if @client.code == 200
        return @client.body
      else
        raise Quasar::FetcherError.new("Failed to access #{url}. Server returned code #{@client.code}.")
      end

    end

    # Sends a POST request to a URL
    def post(url, data = {}, headers = {})
      
      opts = {body: data}

      @client = HTTParty.post(url, opts)
      if @client.code == 200
        return @client.body
      else
        raise Quasar::FetcherError.new("Failed to access #{url}. Server returned code #{@client.code}.")
      end

    end

  end
end