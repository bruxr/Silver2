class Cinema < ActiveRecord::Base

  has_many :movies, through: :schedules

end
