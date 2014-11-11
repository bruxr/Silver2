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
  def find_title(title, year = Date.today.year)

    data = {
      max_pages: 1,
      title: title
    }
    
    begin
      resp = query('/search/movie', data)
    # If we receive a 502, the movie isn't on metacritic.
    rescue WebClient::HTTPError => e
      resp = nil if e.code == 502
    # Otherwise if the API goes through and we hit a false result,
    # set the response to nil
    else
      resp = nil if resp['result'] == false
    end

    # Exit early if response is nil or there are no items/results to process
    return nil if resp.nil? || resp['count'] == 0
    
    result = {}
    scores = {}

    resp['results'].each_with_index do |search_result, index|
      
      # Skip movies that isn't released on the same year
      result_year = search_result['rlsdate'][0..4].to_i
      next if result_year != year
      
      scores[index] = Levenshtein.distance(title, search_result['name'])
      
    end
    
    if scores.empty?
      use_index = 0
    else
      use_index = scores.key(scores.values.min)
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

    critic_score = resp['score'].to_f / 10
    user_score = resp['userscore'].to_f
    score = 10 * ((critic_score + user_score) / 20)
  
    if score == 0
      nil
    else
      score
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

    begin
      response = post(url, data, headers)
    rescue WebClient::HTTPError => e
      if e.code == 502
        raise Exceptions::QuotaReached.new(self.class.to_s) 
      else
        raise e
      end
    else
      JSON.parse(response)
    end

  end

end