class Cinema < ActiveRecord::Base

  has_many :schedules, inverse_of: :cinema, dependent: :destroy

end
