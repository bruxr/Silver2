json.movie do
  
  json.(@movie, :id, :title, :slug, :overview, :runtime, :aggregate_score, :trailer, :mtrcb_rating, :poster_url, :backdrop_url, :website, :tagline, :release_date)
  
  json.genres @movie.genres.map { |g| g.name }
  json.cast @movie.cast.map { |c| c.name }
  
  if user_signed_in?
    json.(@movie, :status, :created_at, :updated_at)
  end
  
  json.partial false
  
end

json.sources do
  json.array! @movie.sources.select { |s| !s.score.nil? } do |source|
    next if source.score.nil?
    json.(source, :id, :movie_id, :url, :score)
    json.name source.friendly_name
  end
end

json.schedules @movie.schedules.scope.upcoming.limit(5)