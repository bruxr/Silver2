json.cinemas do |json|
  json.array! @cinemas do |cinema|
    json.merge! cinema.attributes
  end
end