json.movies do |json|
  json.partial! 'movies/movie', collection: @movies, as: :movie
end