# Lightweight client to the OMDB API (http://www.omdbapi.com)
class Omdb < Quasar::WebClient

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
  def get_details(id)

    resp = query({i: id})

    # Replace N/A with nils
    resp.each do |key, value|
      if value == 'N/A'
        resp[key] = nil
      end
    end

    resp

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