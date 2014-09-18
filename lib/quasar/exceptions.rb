module Quasar
  module Exceptions

    # Generic class for errors when accessing websites.
    # Pass in a HTTParty::Response object if it's available:
    # raise SiteError.new(response), "Failed to access website!"
    class SiteError < StandardError
      attr_reader :response

      def initialize(message, response = nil)
        super(message)
        @response = response unless response.nil?
      end
    end

    # Raised when a parser failed to find an item in a page.
    # Pass in the page url:
    # raise ParsingError.new('http://www.google.com'), "Where is the love?"
    class ParsingError < SiteError
      attr_reader :url

      def initialize(message, url = nil)
        super(message)
        @url = url
      end
    end

    # Generic error that is raised when we can't find something
    # we needed. (e.g. Movie title not found)
    class NothingFound < SiteError
    end

    # Raised when a HTTP request received a page that 
    # it doesn't expect. (e.g. got redirected to another page)
    # Pass in the URL when raising the error:
    # raise UnexpectedUrl.new(url), "Got redirected to the login page!"
    class UnexpectedUrl < SiteError
      attr_reader :url

      def initialize(message, url)
        super(message)
        @url = url
      end
    end

    # Raised when a HTTP request resolves to a non HTTP 200 "OK" response.
    # Pass in a HTTParty::Response object:
    # raise SiteError.new(response), "Received 500 Server Error."
    class HTTPError < SiteError
      attr_reader :response

      def initialize(message, response)
        super(message)
        @response = response
      end
    end

    # Raised when we reach API limits.
    class ReachedLimit < SiteError
    end

  end
end