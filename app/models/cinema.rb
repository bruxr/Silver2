class Cinema < ActiveRecord::Base
  include Sluggable

  has_many :schedules, inverse_of: :cinema, dependent: :destroy

  validates :name, presence: true

  # Makes sures that a cinema's status is
  # only of the specified types:
  # active - active & open cinema
  # hidden - active & open but not shown to visitors
  # disabled - closed cinema, no syncs or scraping.
  validates :status, inclusion: {
    in: %w(active inactive hidden disabled),
    message: "%{value} can only be active, inactive, hidden or disabled."
  }

  slugify :name

  # Scope for finding active cinemas
  def self.is_active
    where(status: 'active')
  end

  # Scope for finding cinemas with a scraper class
  def self.has_scraper
    where.not(fetcher: '')
  end

  # Alias to scraper
  def get_scraper
    scraper
  end
  
  # Returns an instance of the cinema's scraper.
  def scraper
    raise "#{self.name} has no scraper class." if self.fetcher.nil?
    if @scraper.nil?
      @scraper = self.fetcher.constantize.new
    else
      @scraper
    end
  end
  
  # Returns TRUE if the cinema has a scraper.
  def scraper?
    !self.fetcher.nil?
  end

end
