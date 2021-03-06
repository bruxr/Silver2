class Movie < ActiveRecord::Base
  include Sluggable

  has_many :schedules, inverse_of: :movie, dependent: :destroy
  
  # DEPRECATED
  # This is anti pattern since Movie knows what are the internals
  # of a schedule (screening_time).
  # Use movie.schedules.scope.upcoming instead.
  has_many :upcoming_schedules, -> { where('screening_time > ?', Time.now) }, class_name: 'Schedule'

  # Declares that many web services (e.g. The Movie Database)
  # may contain a record of this movie.
  has_many :sources, inverse_of: :movie, dependent: :destroy, autosave: true
  
  # Genres & Cast
  has_and_belongs_to_many :genres
  has_and_belongs_to_many :cast, class_name: 'Artist'
  
  # Convert 'none' & empty MTRCB ratings to nil
  before_validation :convert_blank_mtrcb_rating

  # Make sure we have a title and it is unique.
  validates :title, presence: true
  validates :title, uniqueness: true

  # Make sure the MTRCB rating is a valid one if it exists.
  MTRCB_RATINGS = %w(G PG R-13 R-16 R-18)
  validates :mtrcb_rating, inclusion: {
    in: Movie::MTRCB_RATINGS,
    message: "%{value} is not a valid MTRCB Rating.",
    allow_nil: true
  }
  
  validates :aggregate_score, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 10,
    allow_nil: true
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
      
      sources = [Omdb, Tmdb, RottenTomatoes]
      sources.each do |source|
        res = source.new.find_title(title)
        fixed = res[:title] unless res.nil?
        break unless fixed.nil?
      end

      fixed

    end

    result

  end

  # Creates a non persistent Movie object using the provided details.
  # Used by the Cinema model so it won't know about the attributes needed nor 
  # the preprocessing a movie may need when initialized.
  def self.find_or_initialize(title, rating: nil)

    raise DeprecatedMethod

    fixed = Movie.fix_title(title)
    title = fixed unless fixed.nil?
    movie = Movie.find_or_initialize_by(title: title)
    movie.mtrcb_rating = rating unless rating.nil?

    movie

  end
  
  # Creates movie records for scraped movies from cinema websites.
  def self.process_scraped_movie(movie, cinema)
    
    # Raise an error immediately if we have no title
    raise 'Missing movie title' if movie[:name].nil?
    
    # Try to fix the title.
    title = Movie.fix_title(movie[:name].strip)
    title = movie[:name].strip.downcase.titleize if title.nil?
    
    begin
      mov = Movie.find_or_create_by!(title: title) # Create immediately, to prevent race conditions
    rescue ActiveRecord::RecordNotUnique => e
      mov = Movie.find_by!(slug: Movie.to_slug(title))
    end
    mov.mtrcb_rating = movie[:rating] if mov.mtrcb_rating.nil?
    mov.find_sources! if mov.sources.empty?
    
    movie[:schedules].each do |sked|
      unless Schedule.existing?(mov, cinema, sked[:time], sked[:cinema_name])
        s = Schedule.new
        s.cinema_id = cinema.id
        s.screening_time = sked[:time]
        s.format = sked[:format]
        s.ticket_url = sked[:ticket_url]
        s.ticket_price = sked[:price]
        s.room = sked[:cinema_name]
        mov.schedules << s
      end
    end
    
    mov
    
  end
  
  # Searches the interwebs for a suitable movie poster or backdrop.
  # type can either be 'poster' or 'backdrop'.
  def self.image_search(title, type, year = Date.today.year)
    
    allowed_types = ['.gif', '.jpeg', '.jpg', '.png']
    
    params = {
      searchType: 'image',
      safe: 'medium',
      imgSize: 'large'
    }
    
    resp = Google.new.search("#{title} #{type} #{year}", params)
    
    if resp['queries']['request'].first['count'].to_i == 0
      Rails.logger.warn("Movie - Failed to find a movie #{type} for \"#{title}\.")
      return nil
    end
    
    result = nil
    resp['items'].each do |i|
      ext = File.extname(i['link'])
      if type == 'poster'
        if i['image']['height'] > i['image']['width'] && allowed_types.include?(ext)
          Rails.logger.info("Movie - Using movie poster %s for \"%s.\"" % [i['link'], title])
          result = i['link']
          break
        end
      elsif type == 'backdrop'
        if i['image']['width'] > i['images']['height'] && allowed_types.include?(ext)
          Rails.logger.info("Movie - Using movie backdrop %s for \"%s.\"" % [i['link'], title])
          result = i['items']['link']
          break
        end
      end
    end
    
    result
    
  end
  
  def self.find_poster_for(title)
    url = self.image_search(title, 'poster')
    Yoyo.download(url).upload_using! PosterUploader
  end
  
  def self.find_backdrop_for(title)
    url = self.image_search(title, 'poster')
    Yoyo.download(url).upload_using! BackdropUploader
  end
  
  # Searches for this movie's sources.
  def find_sources!
    
    if self.release_date.nil?
      year = Date.today.year
    else
      year = self.release_date.year
    end
    
    saved_sources = []
    self.sources.each do |source|
      saved_sources << source.name
    end
    
    self.sources << Source.find_sources_for(self.title, {except: saved_sources, year: year});
    
  end

  # DEPRECATED!
  # Use bang! method instead.
  def find_details
    raise DeprecatedMethod
  end

  # Searches for this movie's details like overview, runtime, trailer.
  # This requires that the movie has sources.
  def find_details!
    
    raise 'No sources to use.' if self.sources.empty?

    whitelist = %w(overview runtime poster backdrop release_date tagline website)

    result = Source.find_movie_details(self.sources)
    whitelist.each do |detail|
      self.send("#{detail}=", result[detail])
    end
    
    self.find_poster! if self.poster.nil?
    self.find_backdrop! if self.backdrop.nil?
    
    unless result['genre'].blank?
      result['genre'].each do |g|
        g = g.strip.titleize
        begin
          genre = Genre.find_or_create_by!(name: g)
        rescue ActiveRecord::RecordNotUnique => e
          genre = Genre.find_by(name: g)
        ensure
          self.genres << genre unless self.genres.include?(genre)
        end
      end
    end
    
    unless result['cast'].blank?
      result['cast'].each do |c|
        c = c.strip.titleize
        begin
          cst = Artist.find_or_create_by!(name: c)
        rescue ActiveRecord::RecordNotUnique => e
          cst = Artist.find_by(name: c)
        else
          self.cast << cst unless self.cast.include?(cst)
        end
      end
    end
    
  end

  # DEPRECATED!
  # Use the bang! method instead
  def find_trailer
    raise DeprecatedMethod
  end
  
  # Sets the trailer for this movie.
  # Doesn't set anything if it cannot find a trailer.
  def find_trailer!
    
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
  def update_scores!

    total = 0
    divisor = 0
    self.sources.each do |source|
      if source.can_score?
        
        source.update_score!
        
        unless source.score.nil?
          total += source.score
          divisor += 1
        end
        
      end
    end

    self.aggregate_score = total / divisor if divisor > 0

  end
  
  # Searches for a movie poster using Google and then
  # sets it as the movie's current poster.
  def find_poster!
    self.poster = self.class.find_poster_for(self.title)
  end
  
  # Searches for a movie backdrop using Google and then
  # sets it as the movie's current poster.
  def find_backdrop!
    self.backdrop = self.class.find_backdrop_for(self.title)
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
  
  # Returns TRUE if this movie has incomplete details
  def incomplete?
    self.status == 'incomplete'
  end
  
  # Returns TRUE if this movie is ready for primetime.
  # (e.g. Has complete details)
  def ready?
    self.status == 'ready'
  end

  # Returns the complete movie poster URL with the provided width.
  # If the width isn't supported by TMDB, it uses the highest & nearest width.
  def poster_url(width = 350)
    if self.poster.nil?
      nil
    elsif self.poster =~ /http/
      self.poster
    else
      Tmdb.new.get_poster(self.poster, width)
    end
  end
  
  # Returns the complete movie backdrop URL with the provided width.
  # If the width isn't supported by TMDB, it uses the highest & nearest width.
  def backdrop_url(width = 640)
    if self.backdrop.nil?
      nil
    elsif self.backdrop =~ /http/
      self.backdrop
    else
      Tmdb.new.get_backdrop(self.backdrop, width)
    end
  end

  # Returns the total number of schedules for this movie
  def schedule_count(filter = :all)
    if filter == :upcoming
      upcoming_schedules.count
    else
      schedules.count
    end
  end

  # Returns the total number of cinemas screening this movie
  def cinema_count(filter = :all)
    if filter == :upcoming
      upcoming_schedules.scope.distinct.count(:cinema_id)
    else
      schedules.scope.distinct.count(:cinema_id)
    end
  end
  
  # Rounds the aggregate score to 1 decimal place.
  def aggregate_score=(s)
    super(s.round(1))
  end
    
  # Converts 'None' & empty '' MTRCB ratings to nil.
  def convert_blank_mtrcb_rating
    unless self.mtrcb_rating.nil?
      self.mtrcb_rating = nil if self.mtrcb_rating.downcase == 'none' || self.mtrcb_rating.blank?
    end
  end

end
