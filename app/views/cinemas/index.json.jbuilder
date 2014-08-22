json.array!(@cinemas) do |cinema|
  json.extract! cinema, :id
  json.url cinema_url(cinema, format: :json)
end
