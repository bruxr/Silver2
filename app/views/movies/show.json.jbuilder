json.movie do
  
  json.(@movie, :id, :title, :slug, :overview, :runtime, :aggregate_score, :trailer, :mtrcb_rating, :poster_url, :backdrop_url, :website, :tagline, :release_date, :is_hidden)
  
  json.genres @movie.genres.map { |g| g.name }
  json.cast @movie.cast.map { |c| c.name }
  
  if user_signed_in?
    json.(@movie, :status, :created_at, :updated_at)
  end
  
  json.partial false
  
end

json.sources do
  json.array! @movie.sources.select { |s| !s.score.nil? } do |source|
    json.(source, :id, :movie_id, :external_id, :url, :score)
    json.name source.friendly_name
    json.short_name source.name
  end
end

schedules = @movie.schedules.scope.upcoming.order(screening_time: :desc).limit(5)
json.schedules do
  json.array! schedules do |schedule|
    json.(schedule, :id, :movie_id, :cinema_id, :format, :ticket_url, :ticket_price, :room)
    json.screening_time schedule.screening_time.in_time_zone(Rails.configuration.time_zone)
  end 
end

json.schedules @movie.schedules.scope.upcoming.limit(5)