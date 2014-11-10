json.schedules do |json|
  json.array! @schedules do |schedule|
    json.merge! schedule.attributes
  end
end