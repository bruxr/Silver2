# The base class for all Cinema scrapers.
# Functions as an interface that defines what methods
# a scraper should have.
#
# The sanitize gem is available so you can use it to
# clean up scraped information.
class Scraper < WebClient

  attr_reader :schedules

  # Setups an empty array as schedules
  def initialize
    @schedules = []
    require 'sanitize'
  end

  # Subclasses should override this method
  def get_schedules
    raise NotImplementedError.new
  end

end