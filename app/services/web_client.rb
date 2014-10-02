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
      message = Rack::Utils::HTTP_STATUS_CODES[@response.code]
      raise "Received HTTP #{@response.code} #{message} for #{url}."
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
      message = Rack::Utils::HTTP_STATUS_CODES[@response.code]
      raise "Received HTTP #{@response.code} #{message} for #{url}."
    end

  end

end