json.movies do |json|
  json.array! @movies do |movie|
    json.(movie, :id, :title, :slug, :poster_url, :runtime, :mtrcb_rating)
    json.partial true
  end
end