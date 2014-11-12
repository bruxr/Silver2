json.(movie, :id, :title, :slug, :overview, :runtime, :aggregate_score, :trailer, :mtrcb_rating, :poster_url, :backdrop_url, :website, :tagline, :release_date, :is_hidden)
json.genres movie.genres.map { |g| g.name }
json.cast movie.cast.map { |c| c.name }
if user_signed_in?
  json.(movie, :status, :created_at, :updated_at)
end