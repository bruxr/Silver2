# A Source represents a movie information & score
# source like Rotten Tomatoes and IMDB.
class Source < ActiveRecord::Base

  belongs_to :movie
  validates :movie, presence: true

  validates :external_id, presence: true

  validates :name, inclusion: {
    in: %w(metacritic omdb rt tmdb),
    message: "%{value} is not a valid source."
  }

  validates :score, numericality: {
    allow_nil: true,
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 10
  }

  validates :url, format: {
    with: /\Ahttps?\:\/\/[^\n]+\z/i,
    allow_nil: true,
    message: "is not a valid URL."
  }

  # Returns an array of sources that contains
  # a movie titled with the provided param.
  def self.find_movie_sources(title)

    sources = []
    services = [Metacritic, Omdb, RottenTomatoes, Tmdb]

    # Loop through each website
    services.each do |klass|
      
      service = klass.new
      resp = service.find_title(title)

      # Skip source if it didn't find anything
      next if resp.nil?

      # Source name
      source = klass.to_s.downcase
      source = 'rt' if source == 'rottentomatoes' # Shorten rotten tomatoes

      # Build the model and then add 
      sources << Source.new({
        name: source,
        external_id: resp[:id],
        url: resp[:url]
      });

    end

    sources

  end

end
