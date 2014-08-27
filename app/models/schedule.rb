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
    greater_than_or_equal_to: 0,
    allow_nil: true
  }

  # Convenience function for
  # checking if a schedule already exists
  # with the provided details.
  def self.existing?(movie, cinema, time, room)
    
    movie = movie.id if movie.instance_of?(Movie)
    cinema = cinema.id if cinema.instance_of(Cinema)

    where({
      movie_id: movie,
      cinema_id: cinema,
      screening_time: time,
      room: room
    }).exists?

  end

end
