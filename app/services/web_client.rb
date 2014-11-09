# Web_Client is a simple wrapper to the HTTParty gem
# providing basic get & post methods for connecting to
# the interwebz.
#
# All web clients should include this class and then use
# the provided methods to access URLs.
# A @response variable (HTTParty::Response) is available afterwards for
# inspecting response headers and status code.
class WebClient
  include HTTParty
  
  default_timeout 15
  
  # Returned when the WebClient receives a
  # non 200 OK response.
  class HTTPError < StandardError
    
    attr_reader :code, :url
    
    def initialize(code, url)
      @code = code
      @url = url
    end
    
    def status
      Rack::Utils::HTTP_STATUS_CODES[@code]
    end
    
    def message
      "Received HTTP status #{@code} #{status} from #{@url}."
    end
    
  end

  # Performs a GET request.
  # Pass in a data hash to send query string/parameters.
  # Pass in a headers hash for any custom headers you may need.
  def get(url, data = {}, headers = {})

    options = {
      query: data,
      headers: headers
    }

    @response = self.class.get(url, options)
    if @response.code == 200
      @response.body
    else
      raise WebClient::HTTPError.new(@response.code, url)
    end

  end

  # Sends a POST to a url.
  # Pass a data hash to send post data/values.
  # Pass a headers hash for any custom headers you may need.
  def post(url, data = {}, headers = {})
    
    options = {
      body: data,
      headers: headers
    }

    @response = self.class.post(url, options)
    if @response.code == 200
      @response.body
    else
      raise WebClient::HTTPError.new(@response.code, url)
    end

  end

  # Removes all HTML elements in a string.
  def sanitize_string(value)
    require 'sanitize'
    Sanitize.fragment(value)
  end

  # Works the same as sanitize_string except it works
  # for hashes.
  def sanitize_hash(hash)
    require 'sanitize'
    cleaned = {}
    hash.each do |key, value|
      if value.instance_of? Hash
        cleaned[key] = sanitize_hash(value)
      elsif value.instance_of? Array
        cleaned[key] = sanitize_array(value)
      else
        cleaned[key] = Sanitize.fragment(value.to_s)
      end
    end
    cleaned
  end

  # Works the same as sanitize_string except it works for
  # array types.
  def sanitize_array(array)
    require 'sanitize'
    cleaned = []
    array.each_with_index do |value, index|
      cleaned[index] = value
    end
    cleaned
  end

end