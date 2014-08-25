class Schedule < ActiveRecord::Base

  belongs_to :cinema, inverse_of: :schedules
  belongs_to :movie, inverse_of: :schedules

end
