module Quasar
  module Exceptions

    # Generic class for errors when accessing websites.
    # Pass in a HTTParty::Response object if it's available:
    # raise SiteError.new(response), "Failed to access website!"
    class SiteError < IOError
      attr_reader :response

      def initialize(response = nil)
        @response = response unless response.nil?
      end
    end

    # Raised when a HTTP request received a page that 
    # it doesn't expect. (e.g. got redirected to another page)
    # Pass in the URL when raising the error:
    # raise UnexpectedUrl.new(url), "Got redirected to the login page!"
    class UnexpectedUrl < SiteError
      attr_reader :url

      def initialize(url)
        @url = url
      end
    end

    # Raised when a HTTP request resolves to a non HTTP 200 "OK" response.
    # Pass in a HTTParty::Response object:
    # raise SiteError.new(response), "Received 500 Server Error."
    class HTTPError < SiteError
      attr_reader :response

      def initialize(response)
        @response = response
      end
    end

  end
end