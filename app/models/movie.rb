class Movie < ActiveRecord::Base
  include Sluggable

  has_many :schedules, inverse_of: :movie, dependent: :destroy

  validates :mtrcb_rating, inclusion: {
    in: %w(G PG R-13 R-16 R-18),
    message: "%{value} is not a valid MTRCB Rating.",
    allow_nil: true
  }

  slugify :title

end
