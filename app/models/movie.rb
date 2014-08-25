class Movie < ActiveRecord::Base
  include Sluggable

  has_many :cinemas, through: :schedules

  slugify :title
end
