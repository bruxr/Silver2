# Updates Movie scores/ratings from it's different sources.
# Runs every 6 hours.
class UpdateMovieScoresJob
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { daily.hour_of_day(6, 12, 18, 24) }

  def perform

    movies = Movie.now_showing.includes(:sources).all
    movies.each.do |movie|
      Quasar::ScoreUpdater.new(movie).perform
    end

    Rails.logger.info("Movie scores successfully updated. #{movies.count} items processed.")

  end

end