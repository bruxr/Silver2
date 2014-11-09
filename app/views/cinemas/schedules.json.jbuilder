json.schedules do |json|
  json.array! @schedules do |sked|
    json.merge! sked.attributes
    json.movie sked.movie.title
  end
end