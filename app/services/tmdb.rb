# Lightweight client to The Movie DB API.
# Initialize with an API key, then invoke
# get() with the method name and the params
# you need. Tmdb will automatically add
# the API key.
class Tmdb < WebClient

  @@api_endpoint = 'https://api.themoviedb.org/3'

  def initialize
    @api_key = ENV['TMDB_API_KEY']
  end

  # Convenience method for get_image for movie posters.
  def get_poster(file, size = 'original', secure = true)
    get_image('poster', file, size, secure)
  end

  # Convenience method for get_image for backdrops.
  def get_backdrop(file, size = 'original', secure = true)
    get_image('backdrop', file, size, secure)
  end

  # Returns the full URL to a image given a size & type.
  # - size can either be original or any integer. get_image
  #   will find the nearest size if it isn't supported by TMDB.
  # - type can either be 'poster' or 'backdrop'
  # - set secure to TRUE to return a HTTPS url
  def get_image(type, file, size = 'original', secure = true)

    raise "Invalid image type: #{type}" if type != 'backdrop' && type != 'poster'

    # Find the nearest size if it isn't original.
    if size != 'original'
      config = Rails.cache.read("tmdb:config")
      raise "Cannot find preprocessed sizes" if config['preprocessed_sizes'].nil?
      raise "Cannot find preprocessed #{type} sizes." if config['preprocessed_sizes'][type].nil?
      size = closest_in(config['preprocessed_sizes'][type], size)
      size = "w#{size}"
    end

    # Determine the base URL
    config = Rails.cache.read('tmdb:config')
    if secure
      base_url = config['images']['secure_base_url']
    else
      base_url = config['images']['base_url']
    end

    "#{base_url}#{size}#{file}"

  end

  # Caches TMDB configuration.
  def cache_configuration(duration = 30.days)
    Rails.cache.write('tmdb:config', get_configuration, { expires_in: duration })
  end

  # Returns TMDB configuration.
  def get_configuration

    config = query('/configuration')

    # Build an array of integer sizes without the "w" prefix
    # These arrays are used for finding the nearest image size so
    # we don't need to recreate those arrays everytime we generate
    # an image URL.
    config['preprocessed_sizes'] = {}
    ['backdrop', 'poster'].each do |type|

      config['preprocessed_sizes'][type] = config['images']["#{type}_sizes"].select { |i| true if i != 'original' }.map { |i|
        i.gsub('w', '').to_i
      }

    end

    config

  end

  # Convenience method for searching TMDB for
  # a movie title, returns TMDB's movie title
  # ID and URL or nil if nothing is returned.
  def find_title(title)
    
    data = { query: title }

    resp = query('/search/movie', data)
    unless resp.nil?
      unless resp['results'].empty?
        res = {
          id: resp['results'][0]['id'].to_i,
          title: resp['results'][0]['title'],
          url: "https://www.themoviedb.org/movie/#{resp['results'][0]['id']}"
        }
      end
    end

  end

  # Convenience method for grabbing details
  # for a specific movie using the given
  # movie ID.
  def get_raw_details(id)

    result = query("/movie/#{id}")
    sanitize_hash(result)

  end

  # Returns normalized hash of details for a movie
  # given a TMDB movie ID.
  # Take note that the hash follows Silver's movie details
  # conventions (e.g. lowercase keys, overview for plot, etc)
  def get_details(id)

    result = get_raw_details(id)

    require 'date'

    details = {}
    details['title'] = result['title']
    details['release_date'] = Date.parse(result['release_date'])
    details['genre'] = []
    result['genres'].each do |genre|
      details['genre'] << genre['name']
    end
    details['runtime'] = result['runtime'].to_i
    details['poster'] = result['poster_path']
    details['overview'] = result['overview']
    details['tagline'] = result['tagline']
    details['backdrop'] = result['backdrop_path']
    details['website'] = result['homepage']

    details

  end

  # Returns the movie's score in TMDB.
  def get_score(id)

    details = get_details(id)

    if details.nil?
      nil
    else
      details['vote_average'].to_f
    end

  end

  # Common query method to access the API.
  def query(method, params = {})

    params[:api_key] = @api_key
    url = "#{@@api_endpoint}#{method}"

    response = get(url, params)
    JSON.parse(response)

  end

  private

    # Returns the number nearest to input from a set of numbers arr.
    # Used by the image functions to return the nearest image size.
    def closest_in(arr, input)
      arr.min_by { |x| (x.to_f - input).abs }
    end

end