# The base class for all Cinema scrapers.
# Functions as an interface that defines what methods
# a scraper should have.
#
# The sanitize gem is available so you can use it to
# clean up scraped information.
class Scraper < WebClient

  # Setups an empty array as schedules
  def initialize
    @schedules = []
    require 'sanitize'
  end

  # Subclasses should override this method
  def schedules
    raise NotImplementedError.new
  end

  # Returns an array of movie titles from the
  # scraped schedules.
  def titles
    schedules.map { |s| s[:name] }
  end

end