json.(movie, :id, :title, :slug, :overview, :runtime, :aggregate_score, :trailer, :mtrcb_rating, :poster_url, :backdrop_url)
if user_signed_in?
  json.(movie, :status, :created_at, :updated_at)
end