class Movie < ActiveRecord::Base
  include Sluggable

  has_many :schedules, inverse_of: :movie, dependent: :destroy

  # Declares that many web services (e.g. The Movie Database)
  # may contain a record of this movie.
  has_many :sources, inverse_of: :movie, dependent: :destroy do

    # Searches for this movie's external sources.
    # Take note that this will set and overwrite existing
    # sources with the found sources.
    def search
      raise 'Movie title is nil.' if proxy_association.owner.title.nil?
      proxy_association.owner.sources << Source.find_movie_sources(proxy_association.owner.title)
    end

  end

  validates :title, presence: true

  validates :mtrcb_rating, inclusion: {
    in: %w(G PG R-13 R-16 R-18),
    message: "%{value} is not a valid MTRCB Rating.",
    allow_nil: true
  }

  slugify :title

  # Scope for finding movies that are still "now showing".
  # e.g. still has future schedules.
  def self.now_showing
    joins(:schedules).where('schedules.screening_time > ?', Time.now)
  end

  # Scope for finding movies that contains incomplete details.
  def self.incomplete
    where(status: 'incomplete')
  end

  # Fixes the movie's title that may have spelling errors, extra characters
  def fix_title

    cache_key = "fixed_titles:#{title.parameterize}"

    # Check cache if we already have searched for this title
    result = Rails.cache.fetch(cache_key) do

      fixed = nil

      # Search TMDB
      tmdb = Tmdb.new
      tmdb_res = tmdb.find_title(title)
      unless tmdb_res.nil?
        fixed = tmdb_res[:title]
      end

      # If we can't find it on TMDB, check Rotten Tomatoes
      if fixed.nil?
        rt = RottenTomatoes.new
        rt_res = rt.find_title(title)
        unless rt_res.nil?
          fixed = rt_res[:title]
        end
      end

      # If we can't find it on both TMDB & RT, check OMDB/Freebase
      if fixed.nil?
        omdb = Omdb.new
        omdb_res = omdb.find_title(title)
        unless omdb_res.nil?
           fixed = omdb_res[:title]
        end
      end

      # If we can't still find the title, raise an error.
      # Otherwise update the attribute.
      if fixed.nil?
        raise "Failed to fix movie title: #{original}"
      else
        self.title = fixed
      end

    end

  end

end
