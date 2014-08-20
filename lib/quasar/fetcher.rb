class Quasar::Fetcher

  # Sends a GET request to a URL
  def get(url, data = {}, headers = {})



  end

  # Sends a POST request to a URL
  def post(url, data = {}, headers = {})
    
    http = Curl.post url, data
    return http.body_str

  end

end