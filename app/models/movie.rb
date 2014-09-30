class Movie < ActiveRecord::Base
  include Sluggable

  has_many :schedules, inverse_of: :movie, dependent: :destroy

  has_many :sources, inverse_of: :movie, dependent: :destroy

  validates :title, presence: true

  validates :mtrcb_rating, inclusion: {
    in: %w(G PG R-13 R-16 R-18),
    message: "%{value} is not a valid MTRCB Rating.",
    allow_nil: true
  }

  slugify :title

  # Scope for finding movies that are still "now showing".
  # e.g. still has future schedules.
  def self.now_showing
    joins(:schedules).where('schedules.screening_time > ?', Time.now)
  end

  # Scope for finding movies that contains incomplete details.
  def self.incomplete
    where(status: 'incomplete')
  end

end
