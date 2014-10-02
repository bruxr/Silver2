# Lightweight client to The Movie DB API.
# Initialize with an API key, then invoke
# get() with the method name and the params
# you need. Tmdb will automatically add
# the API key.
class Tmdb < Quasar::WebClient

  @@api_endpoint = 'https://api.themoviedb.org/3'
  @@images_base_url = 'https://image.tmdb.org/t/p'

  def initialize(api_key)
    @api_key = api_key
  end

  # Builds image URLs for backdrops & posters.
  def image(image, size = 'original')

    @@images_base_url << "/#{size}#{image}"

  end

  # Returns TMDB configuration.
  def get_configuration

    query('/configuration')

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
  def get_details(id)

    query("/movie/#{id}")

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

end