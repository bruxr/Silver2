class Quasar::Fetcher

  # Sends a GET request to a URL
  def get(url, data = {}, headers = {})

    url << data.to_query
    http = Curl.get url
    return http.body_str

  end

  # Sends a POST request to a URL
  def post(url, data = {}, headers = {})
    
    http = Curl.post url, data
    return http.body_str

  end

end