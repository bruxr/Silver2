class Cinema < ActiveRecord::Base
  include Sluggable

  has_many :schedules, inverse_of: :cinema, dependent: :destroy

  validates :name, presence: true

  # Makes sures that a cinema's status is
  # only of the specified types:
  # active - active & open cinema
  # hidden - active & open but not shown to visitors
  # disabled - closed cinema, no syncs or scraping.
  validates :status, inclusion: {
    in: %w(active inactive hidden disabled),
    message: "%{value} can only be active, inactive, hidden or disabled."
  }

  slugify :name

end
