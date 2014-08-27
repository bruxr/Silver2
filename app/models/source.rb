# A Source represents a movie information & score
# source like Rotten Tomatoes and IMDB.
class Source < ActiveRecord::Base

  belongs_to :movie
  validates :movie, presence: true

  validates :external_id, presence: true

  validates :name, inclusion: {
    in: %w(metacritic omdb rt tmdb),
    message: "%{value} is not a valid source."
  }

  validates :score, numericality: {
    allow_nil: true,
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 10
  }

  validates :url, format: {
    with: /\Ahttps?\:\/\/[^\n]+\z/i,
    allow_nil: true,
    message: "is not a valid URL."
  }

end
