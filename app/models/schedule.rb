class Schedule < ActiveRecord::Base

  belongs_to :cinema, inverse_of: :schedules
  validates :cinema, presence: true

  belongs_to :movie, inverse_of: :schedules
  validates :movie, presence: true

  validates :screening_time, presence: true

  validates :format, inclusion: {
    in: %w(2D 3D IMAX),
    message: "%{value} is not a valid film format."
  }

  validates :ticket_url, format: {
    with: /\Ahttps?\:\/\/[^\n]+\z/i,
    allow_nil: true,
    message: "is not a valid URL."
  }

  validates :ticket_price, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0,
    allow_nil: true
  }

end
