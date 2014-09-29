# Updates a movie's details like overview, posters, backdrop
class GetSchedulesJob
  include Sidekiq::Worker

  def perform(movie_id)

    movie = Movie.find(movie_id)
    
    updater = Quasar::MovieUpdater.new(movie)
    updater.perform

  end

end