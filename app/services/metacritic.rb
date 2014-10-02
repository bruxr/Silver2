# Metacritic API Client through the Unofficial API in Mashape
# https://www.mashape.com/byroredux/metacritic
#
# Instantiate with a Mashape API Key
# then invoke the necessary methods.
class Metacritic < Quasar::WebClient

  @@endpoint = 'https://byroredux-metacritic.p.mashape.com'

  def initialize(api_key)
    @api_key = api_key
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
    result = nil
    unless resp.nil?
      if resp['count'] > 0
        result = {
          id: resp['results'][0]['name'],
          title: resp['results'][0]['name'],
          url: resp['results'][0]['url']
        }
      end
    end

    result

  end

  # Fetches movie details using it's title.
  # Take note that metacritic doesn't expose an API
  # so we're just using the movie title as ID :)
  #
  # Important: Use the title returned by find_title() 
  # it's the only 100% sure identifier that will match.
  def get_details(id)

    data = {
      title: id
    }
    resp = query('/find/movie', data)
    unless resp.nil?
      result = resp['result']
      # Add an ID & title to match other web services
      result[:id] = result['name']
      result[:title] = result['name']
    else
      result = nil
    end

    result

  end

  # Returns a movie's score in Metacritic.
  # Set actual to true to return the actual
  # metacritic score, otherwise it'll return
  # a score in the range of 0-10
  def get_score(id, actual = false)

    resp = get_details(id)

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