# Simple API for accessing Google Custom Search
# Initialize with an engine ID (cx, cref) and
# project API Key to use (key)
class Google < WebClient

  @@base_endpoint = 'https://www.googleapis.com'
  @@endpoint = 'https://www.googleapis.com/customsearch/v1'

  def initialize
    @engine_id = ENV['G_CSE_ID']
    @api_key = ENV['G_API_KEY']
  end

  # Performs a search query
  def search(query, params = {})

    defaults = {
      q: query,
      cx: @engine_id,
      key: @api_key
    }
    params = params.merge(defaults)
    response = get(@@endpoint, params)
    JSON.parse(response)

  end

  # Performs a youtube search
  def youtube_search(query, params = {})

    defaults = {
      part: 'snippet',
      q: query,
      key: @api_key
    }
    params = params.merge(defaults)
    response = get("#{@@base_endpoint}/youtube/v3/search", params)
    JSON.parse(response)

  end

end