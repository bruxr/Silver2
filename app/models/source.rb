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

  # Maps source names to the service classes,
  # used for converting 'name' strings to classes.
  @@source_to_class = {
    metacritic: Metacritic,
    omdb: Omdb,
    rt: RottenTomatoes,
    tmdb: Tmdb
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

  # Returns a plethora of information about a movie
  # when provided with an array of Sources.
  #
  # Make sure that all of the sources point to the same movie!
  # Otherwise your information may conflict with each other.
  def self.find_movie_details(sources)

    raise 'No sources to use' if sources.empty?

    # Preferred sources of details for a movie
    preferred_sources = {
      'tmdb' => 0,
      'rt'   => 1,
      'omdb' => 2
    }

    # Build an array of movie ID's for those sources
    # arranged by our preferred sources and if the
    # source is present.
    sorted_sources = []
    sources.each do |source|
      sorted_sources[preferred_sources[source.name]] = source unless preferred_sources[source.name].nil?
    end

    result = {}

    # Now fetch details using our sorted sources, overwriting
    # any missing detail.
    sorted_sources.each do |source|
      next if source.nil? # Skip if the preferred source is missing.
      client = source.client
      client.get_details(source.external_id).each do |key, value|
        if result[key.to_s].nil?
          result[key.to_s] = value
        end
      end
    end

    result

  end

  # Returns an instance of the client for this class.
  # For example, Omdb client for a 'omdb' source
  def client
    klass = @@source_to_class[self.name.to_sym].new
  end

  # Updates the movie's scores based on the source.
  def update_score
    self.score = self.client.get_score(self.external_id)
  end

  # Returns TRUE if this source is included in the aggregate scoring.
  # This usually returns false for sources that has too few voters (TMDB)
  # or doesn't have a ratings system.
  def can_score?
    true if self.name != 'tmdb'
  end

end
