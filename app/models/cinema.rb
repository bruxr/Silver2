class Cinema < ActiveRecord::Base
  include Sluggable

  has_many :schedules, inverse_of: :cinema, dependent: :destroy do

    # Runs the scraper for this cinema fetching new schedules
    # from the cinema's website.
    def fetch_new
      
      raise "#{proxy_association.owner.name} has no scraper class." if proxy_association.owner.fetcher.nil?

      new_movies = []

      # Process each scraped movie & schedules, creating records for both
      # if they don't exist yet.
      results = proxy_association.owner.get_scraper.get_schedules
      results.each do |item|
        
        movie = Movie.find_or_initialize(item[:name], rating: item[:rating])
        
        item[:schedules].each do |sked|
          schedule = Schedule.initialize_if_inexistent(movie, proxy_association.owner, sked[:time], sked[:cinema_name], format: sked[:format], ticket_url: sked[:url], price: sked[:price])
          movie.schedules << schedule unless schedule.nil?
        end
        
        # Save the movie, adding new ones to the new_movies array
        # after a successful save.
        if movie.new_record?
          new_movies << movie if movie.save!
        else
          movie.save!
        end

        new_movies

      end

    end

  end

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

  # Returns an instance of the cinema's scraper.
  def get_scraper
    raise "#{self.name} has no scraper class." if self.fetcher.nil?
    if @scraper.nil?
      @scraper = self.fetcher.constantize.new
    else
      @scraper
    end
  end

end
