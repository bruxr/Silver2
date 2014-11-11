json.schedules do |json|
  json.array! @schedules do |schedule|
    json.merge! schedule.attributes
  end
end

json.cinemas do |json|
  json.array! @cinemas, partial: 'cinemas/mini', as: :cinema
end

json.movies do |json|
  json.array! @movies, partial: 'movies/mini', as: :movie
end