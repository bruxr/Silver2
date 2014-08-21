# The base class for all Quasar fetchers/scrapers/accessors.
# Provides get & post methods for accessing websites
# and returns the unmodified response string.
#
# TODO: add support for custom headers
class Quasar::Fetcher

  attr_reader :schedules

  # Setups an empty array as schedules
  def initialize
    @schedules = []
  end

  # Sends a GET request to a URL
  def get(url, data = {}, headers = {})

    url << '?' << data.to_query unless data.empty?
      
    http = Curl.get url
    return http.body_str

  end

  # Sends a POST request to a URL
  def post(url, data = {}, headers = {})
    
    http = Curl.post url, data
    return http.body_str

  end

end