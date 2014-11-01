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
  def find_title(title, year = Date.today.year)

    resp = query('/movies', {q: title, page_limit: 1, page: 1})
    unless resp.nil? 
      if resp['total'] > 0
        
        result = {}
        resp['movies'].each do |movie|
          if movie['year'] == year
            result[:title] = movie['title']
            result[:id] = movie['id'].to_i
            result[:url] = movie['links']['alternate']
          end
        end
        
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
    details['release_date'] = Date.parse(result['release_dates']['theater']) unless result['release_dates']['theater'].nil?
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

    details = get_raw_details(id)
    
    raise "RottenTomatoes - Failed to fetch details for \##{id}, response is nil." if details.nil?
    
    require 'nokogiri'
    page = get(details['links']['alternate'])
    doc = Nokogiri::HTML(page)
    
    critic_ratings = doc.at_css('#scoreStats > div:first')
    if critic_ratings.nil?
      Rails.logger.warn("RottenTomatoes - Failed to find critics section when calculating scores for \##{id}. No score will be calculated.")
      return nil # Score unavailable if critic scores aren't present.
    end
    
    critics_score = critic_ratings.content.strip.match(/(\d(\.\d)?)\/10/)[0]
    raise "Failed to extract critics score when calculating scores for \##{id}." if critics_score.nil?
    critics_score = critics_score.to_f
    
    audience_ratings = doc.at_css('.audience-info > div:first').content
    raise "Failed to find audience section when calculating scores for \##{id}." if audience_ratings.blank?

    audience_score = audience_ratings.strip.match(/(\d(\.\d)?)\/5/)[0]
    raise "Failed to extract audience score when calculating scores for \##{id}." if audience_score.nil?
    audience_score = audience_score.to_f * 2
    
    (critics_score + audience_score) / 20

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
    begin
      response = get(url, data)
    rescue WebClient::HTTPError => e
      raise Exceptions::QuotaReached.new(self.class.to_s) if e.code == 403
    else
      JSON.parse(response)
    end

  end

end