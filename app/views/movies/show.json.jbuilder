json.movie do |movie|
  json.partial! 'movies/movie', movie: @movie
end