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

  # Make sure we have a title and it is unique.
  validates :title, presence: true
  validates :title, uniqueness: true

  validates :mtrcb_rating, inclusion: {
    in: %w(G PG R-13 R-16 R-18),
    message: "%{value} is not a valid MTRCB Rating."
  }

  slugify :title

  # Scope for finding movies that are still "now showing".
  # e.g. still has future schedules.
  def self.now_showing
    joins(:schedules).where('schedules.screening_time > ?', Time.now).uniq
  end

  # Scope for finding movies that has passed (not showing anymore)
  def self.past
    joins(:schedules).where('schedules.screening_time < ?', Time.now).uniq
  end

  # Scope for finding movies that contains incomplete details.
  def self.incomplete
    where(status: 'incomplete')
  end

  # Fixes movie titles by querying our external movie sources.
  def self.fix_title(title)

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

      fixed

    end

    result

  end

  # Creates a non persistent Movie object using the provided details.
  # Used by the Cinema model so it won't know about the attributes needed nor 
  # the preprocessing a movie may need when initialized.
  def self.find_or_initialize(title, rating: nil)

    fixed = Movie.fix_title(title)
    title = fixed unless fixed.nil?
    movie = Movie.find_or_initialize_by(title: title)
    movie.mtrcb_rating = rating unless rating.nil?

    movie

  end

  # Searches for this movie's details like overview, runtime, trailer.
  # This requires that the movie has sources.
  def find_details

    raise 'No sources to use.' if self.sources.empty?

    details = %w(overview runtime poster backdrop)

    result = Source.find_movie_details(self.sources)
    details.each do |detail|
      self.send("#{detail}=", result[detail])
    end

  end

  # Sets the trailer for this movie.
  # Doesn't set anything if it cannot find a trailer.
  def find_trailer

    raise "Cannot find the movie's title" if self.title.nil?

    google = Google.new
    year = Date.today.strftime('%Y')
    search_query = "#{self.title} #{year} trailer"
    params = {
      type: 'video',
      videoEmbeddable: 'true',
      videoSyndicated: 'true'
    }

    trailers = Hash.new(nil)
    ['high', 'standard'].each do |definition|

      params[:videoDefinition] = definition
      resp = google.youtube_search(search_query, params)

      # Look for the very first video in the search results.
      # After finding one, take note of it then skip the rest.
      resp['items'].each do |item|

        next if item['id']['kind'] != 'youtube#video'

        if trailers[definition] == nil
          trailers[definition] = item['id']['videoId']
          break
        end

      end

    end

    # Set the highest definition video as possible
    if !trailers['high'].nil?
      self.trailer = trailers['high']
    elsif !trailers['standard'].nil?
      self.trailer = trailers['standard']
    end

  end

  # Updates the movie's scores & aggregate score
  def update_scores

    total = 0
    divisor = 0
    self.sources.each do |source|
      if source.can_score?
        source.update_score
        unless source.score.nil?
          total += source.score
          divisor += 1
        end
      end
    end

    self.aggregate_score = total / divisor if divisor > 0

  end

  # Marks the movie as ready if it contains complete
  # details like overview, plot, trailer, etc.
  def update_status

    return if self.status != 'incomplete' # Exit early if this has been processed already

    required_details = %w(overview runtime poster backdrop trailer)
    is_ready = true
    required_details.each do |detail|
      is_ready = false if self.send(detail).nil?
    end

    self.status = 'ready' if is_ready

  end

  # Returns the complete movie poster URL with the provided width.
  # If the width isn't supported by TMDB, it uses the highest & nearest width.
  def poster_url(width = 350)
    if self.poster =~ /http/
      self.poster
    else
      Tmdb.new.get_poster(self.poster, width)
    end
  end

  # Returns the total number of schedules for this movie
  def schedules_count
    schedules.count
  end

  # Returns the total number of cinemas screening this movie
  def schedules_cinema_count
    schedules.scope.distinct.count(:cinema_id)
  end

end
