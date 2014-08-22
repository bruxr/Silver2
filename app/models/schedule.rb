class Schedule < ActiveRecord::Base

  belongs_to :cinema
  belongs_to :movie

end
