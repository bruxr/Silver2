# The base class for all Cinema scrapers.
# Functions as an interface that defines what methods
# a scraper should have.
class Scraper < WebClient

  attr_reader :schedules

  # Setups an empty array as schedules
  def initialize
    @schedules = []
  end

  # Subclasses should override this method
  def get_schedules
    raise NotImplementedError.new
  end

end