# Rotten Tomatoes API Client
# Initialize with an API Key then invoke
# the methods you need.
#
# query() is also available as a generic
# API access method.
class RottenTomatoes < WebClient

  @@endpoint = 'http://api.rottentomatoes.com/api/public/v1.0'

  def initialize
    @api_key = ENV['RT_API_KEY']
  end

  # Searches the Rotten Tomatoes API
  # for a movie title.
  # Returns the title and its ID.
  def find_title(title)

    resp = query('/movies', {q: title, page_limit: 1, page: 1})
    unless resp.nil? 
      if resp['total'] > 0
        result = {
          title: resp['movies'][0]['title'],
          id: resp['movies'][0]['id'].to_i,
          url: resp['movies'][0]['links']['alternate']
        }
      else
        result = nil
      end
    else
      result = nil
    end

    result

  end

  # Returns the details for a movie
  # when provided with a movie ID.
  def get_raw_details(id)
    result = query("/movies/#{id}")
    sanitize_hash(result)
  end

  # Returns a normalized hash of details for a movie.
  # Take note that this follows Silver's conventions
  # for movie details (e.g. in a hash, lowercase keys, 
  # overview for plot, etc.)
  def get_details(id)
    
    result = get_raw_details(id)

    require 'date'
    
    details = {}
    details['title'] = result['title']    
    details['release-date'] = Date.parse(result['release_dates']['theater']) unless result['release_dates']['theater'].nil?
    details['genre'] = result['genres']
    details['runtime'] = result['runtime'].to_i
    details['director'] = result['abridged_directors'].first['name'] unless result['abridged_directors'].nil?
    details['cast'] = []
    result['abridged_cast'].each do |cast|
      details['cast'] << cast['name']
    end
    details['poster'] = result['posters']['original']
    details['overview'] = result['synopsis'].gsub(/\(C\).+$/, '')

    details

  end

  # Returns the movie's rating in Rotten Tomatoes.
  # Set actual to TRUE to return the 0-100 score
  # instead of converted 0-10.
  # Take note that this combines both the critics
  # and the audience score.
  def get_score(id, audiences = false)

    details = get_details(id)

    # If we got an error, end early.
    if details.nil? || details['ratings'].nil?
      nil
    else
      critics = details['ratings']['critics_score'].to_f / 10
      audience = details['ratings']['audience_score'].to_f / 10
      (critics + audience) / 2
    end

  end

  # Generic API querying method.
  # Provide the method (with leading forward-slash)
  # and corresponding parameters to acccess the API. 
  # format (JSON only) and API will be added automatically.
  #
  # Example:
  # query('/movies', {q: 'iron+man'}) for movie search
  # query('/movies/714976247') for a specific movie
  def query(method, data = {})

    data['apikey'] = @api_key

    url = "#{@@endpoint}#{method}.json"
    response = get(url, data)
    JSON.parse(response)

  end

end