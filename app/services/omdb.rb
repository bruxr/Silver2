# Lightweight client to the OMDB API (http://www.omdbapi.com)
class Omdb < WebClient

  @@endpoint = 'http://www.omdbapi.com'

  # Searches the OMDB API given a movie title
  def find_title(title)

    resp = query({s: title})
    result = nil
    unless resp.nil?
      unless resp['Search'].nil?
        resp['Search'].each do |item|
          if item['Type'] == 'movie'
            result = {
              title: item['Title'],
              id: item['imdbID'],
              url: "http://www.imdb.com/title/#{item['imdbID']}"
            }
            break
          end
        end
      end
    end

    result

  end

  # Returns a wealth of information about a movie
  # using its IMDB movie ID
  def get_raw_details(id)

    details = query({i: id})
    sanitize_hash(details)

  end

  # Returns a normalized hash of movie informations using its
  # IMDB movie ID.
  # 
  # Take note that this follows Silver's conventions for movie
  # details. (e.g. lowercase keys, overview for plot)
  def get_details(id)

    result = get_raw_details(id)

    # Convert N/A's to nil
    result.each do |key, value|
      result[key] = nil if value == 'N/A'
    end

    require 'date'

    details = {}
    details['title'] = result['Title']
    details['release-date'] = Date.parse(result['Released']) unless result['Released'].nil?
    details['genre'] = result['Genre'].split(',').map(&:strip).map(&:downcase)
    details['runtime'] = result['Runtime'].gsub('min', '').to_i unless result['Runtime'].nil?
    details['director'] = result['Director']
    details['cast'] = result['Actors'].split(',').map(&:strip)
    details['poster'] = result['Poster']
    details['overview'] = result['Plot']

    details

  end

  # Returns a movie's rating in IMDB.
  def get_score(id)

    resp = get_details(id)

    # Nil for error
    if resp.nil?
      return nil

    # The score for success
    else
      return resp['imdbRating'].to_f
    end

  end

  # Generic query method. Just provide a params hash
  # and it'll take care of the rest :)
  #
  # Params reference: http://www.omdbapi.com/
  def query(data)

    response = get(@@endpoint, data)
    JSON.parse(response)

  end

end