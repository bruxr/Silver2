# Scraping Error Class occurs when an expected value 
# when scraping isn't available, parsable or readable.
#
# Raise this error if scraping cannot be continued.
class Quasar::ScrapingError < StandardError

  attr_reader :message

  def initialize(message, scraper = nil)
    @message = message
    @scraper = scraper
  end

  def message
    if scraper.nil?
      @message
    else
      "#{@scraper}: #{@message}"
    end
  end

  def to_s
    get_message
  end

end