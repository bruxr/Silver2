json.cinemas do |json|
  json.array! @cinemas do |cinema|
    json.(cinema, :id, :name, :slug, :latitude, :longitude, :status, :fetcher, :phone_number, :website, :created_at, :updated_at)
  end
end