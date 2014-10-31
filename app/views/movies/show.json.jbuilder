json.movie do |movie|
  
  json.(@movie, :id, :title, :slug, :overview, :runtime, :aggregate_score, :trailer, :mtrcb_rating, :poster_url, :backdrop_url, :website, :tagline, :release_date)
  
  json.genres @movie.genres.map { |g| g.name }
  json.cast @movie.cast.map { |c| c.name }
  
  if user_signed_in?
    json.(@movie, :status, :created_at, :updated_at)
  end
  
  json.partial false
  
end

json.sources @movie.sources, :id, :name, :url, :score
json.schedules @movie.schedules.scope.upcoming.limit(5)