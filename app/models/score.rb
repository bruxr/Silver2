# A Score represents a movie rating/score from
# from an external site.
class Score < ActiveRecord::Base

  belongs_to :movie
  validates :movie, presence: true

  validates :external_movie_id, presence: true

  validates :source, inclusion: {
    in: %w(metacritic omdb rt tmdb),
    message: "%{value} is not a valid source."
  }

  validates :score, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 10
  }

end
