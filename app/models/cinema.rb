class Cinema < ActiveRecord::Base
  include Sluggable

  has_many :schedules, inverse_of: :cinema, dependent: :destroy

  slugify :name

end
