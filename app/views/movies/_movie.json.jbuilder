json.(movie, :id, :title, :slug, :overview, :runtime, :aggregate_score, :trailer, :mtrcb_rating)
if user_signed_in?
  json.(movie, :created_at, :updated_at)
end