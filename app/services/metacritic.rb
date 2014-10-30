# Metacritic API Client through the Unofficial API in Mashape
# https://www.mashape.com/byroredux/metacritic
#
# Instantiate with a Mashape API Key
# then invoke the necessary methods.
class Metacritic < WebClient

  @@endpoint = 'https://byroredux-metacritic.p.mashape.com'

  def initialize
    @api_key = ENV['MASHAPE_API_KEY']
  end

  # Searches the API for a movie that matches the
  # provided title.
  # Returns a hash of the movie's ID (also the title XD) and title
  def find_title(title)

    data = {
      max_pages: 1,
      title: title
    }
    resp = query('/search/movie', data)

    # Exit early if response is nil or there are no items/results to process
    return nil if resp.nil? || resp['count'] == 0

    use_index = 0 # Use first search result by default
    result = {}

    # Try to find the exact title on the results
    title_dc = title.downcase
    resp['results'].each_with_index do |search_result, index|
      if search_result['name'].downcase == title_dc
        use_index = index
      end
    end

    # Build the result hash
    use_result = resp['results'][use_index]
    result = {
      title: use_result['name'],
      id: use_result['name'],
      url: use_result['url']
    }

  end

  # Fetches movie details using it's title.
  # Take note that metacritic doesn't expose an API
  # so we're just using the movie title as ID :)
  #
  # Important: Use the title returned by find_title() 
  # it's the only 100% sure identifier that will match.
  def get_raw_details(id)

    data = {
      title: id
    }
    resp = query('/find/movie', data)
    unless resp.nil?
      result = resp['result']
      sanitize_hash(result)
    else
      result = nil
    end

    result

  end

  # Fetches "normalized" movie details using its title.
  # Normalized movie details are movie info that follow
  # Silver's conventions. (e.g. lowercase string keys, 
  # overview instead of plot etc.)
  #
  # Take note that metacritic doesn't expose an API
  # so we're just using the movie title as ID :)
  #
  # Important: Use the title returned by find_title() 
  # it's the only 100% sure identifier that will match.
  def get_details(id)

    result = get_raw_details(id)

    require 'date'

    details = {}
    details['title'] = result['name']
    details['release_date'] = Date.parse(result['rlsdate']) unless result['rlsdate'].nil?
    details['genre'] = result['genre'].split("\n").map(&:strip).map(&:downcase)
    details['runtime'] = result['runtime'].gsub('min', '').to_i
    details['director'] = result['director']
    details['cast'] = result['cast'].split(',').map(&:strip)
    details['poster'] = result['thumbnail']

    details

  end

  # Returns a movie's score in Metacritic.
  # Set actual to true to return the actual
  # metacritic score, otherwise it'll return
  # a score in the range of 0-10
  def get_score(id, actual = false)

    resp = get_raw_details(id)

    # If we didn't get anything, return a nil
    return nil if resp.nil?

    score = resp['score'].to_i
    if actual
      score
    else
      score / 10
    end

  end

  # Generic API querying method.
  # Provide the method with the leading forward slash
  # and parameters if necessary.
  #
  # API key will be added to the headers automatically.
  def query(method, data = {})

    headers = {}
    headers['X-Mashape-Key'] = @api_key
    
    url = "#{@@endpoint}#{method}"
    response = post(url, data, headers)
    JSON.parse(response)

  end

end