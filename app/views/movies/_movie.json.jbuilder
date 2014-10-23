json.(movie, :id, :title, :slug, :overview, :runtime, :aggregate_score, :trailer, :mtrcb_rating, :poster_url)
if user_signed_in?
  json.(movie, :status, :schedule_count, :cinema_count, :created_at, :updated_at)
  json.schedule_count = movie.schedule_count(@schedules_filter)
  json.cinema_count = movie.schedule_count(@schedules_filter)
end