class Movie < ActiveRecord::Base

  has_many :cinemas, through: :schedules

end
