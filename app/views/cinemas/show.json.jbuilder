json.cinema do
  json.extract! @cinema, :id, :name, :slug, :latitude, :longitude
  json.extract! @cinema, :status, :fetcher, :created_at, :updated_at if user_signed_in?
end
