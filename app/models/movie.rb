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

  # 
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

    title = Movie.fix_title(title)
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

    require 'google/api_client'
    google = Google::APIClient.new(
      key: ENV['G_API_KEY'],
      authorization: nil,
      application_name: 'Silver',
      application_version: '1'
    )

    year = Date.today.strftime('%Y')
    search_query = "#{self.title} #{year} trailer"

    # Use a cached youtube service if it's present
    youtube = Rails.cache.fetch('youtube-service') do
      google.discovered_api('youtube', 'v3')
    end

    trailers = Hash.new(nil)
    ['high', 'standard'].each do |definition|

      resp = google.execute!(
        api_method: youtube.search.list,
        parameters: {
          part: 'snippet',
          q: search_query,
          maxResults: 25,
          type: 'video',
          videoDefinition: definition,
          videoEmbeddable: 'true',
          videoSyndicated: 'true'
        }
      )

      # Look for the very first video in the search results.
      # After finding one, take note of it then skip the rest.
      resp.data.items.each do |item|

        next if item.id.kind != 'youtube#video'

        if trailers[definition] == nil
          trailers[definition] = item.id.videoId 
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

end
