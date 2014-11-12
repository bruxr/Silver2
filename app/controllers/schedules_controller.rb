class SchedulesController < ApplicationController
  
  # GET /schedules.json route
  # Returns an array of schedules that match the provided options:
  # date - return schedules that are screening on that date (required, defaults to the current date)
  # cinema - return schedules for that cinema (optional, provide cinema ID)
  # movie - return schedules for that movie (optional, provide movie ID)
  #
  # NOTES:
  # - This returns all of the results! Paginate those in your JS.
  # - This provides partial movie & cinema records associated with the schedules.
  def index
    
    if params[:date].nil?
      date = Time.zone.now
    else
      begin
        date = Time.zone.parse(params[:date])
      rescue ArgumentError => e
        date = Time.zone.now
      end
    end
    
    @schedules = Schedule.where(screening_time: date.beginning_of_day..date.end_of_day)
    
    if params[:cinema] =~ /\A\d+\Z/
      cinema_id = params[:cinema].to_i
      @schedules = @schedules.where(cinema_id: cinema_id)
    end
    
    if params[:movie] =~ /\A\d+\Z/
      movie_id = params[:movie].to_i
      @schedules = @schedules.where(movie_id: movie_id)
    end
    
    movies = []
    cinemas = []
    @schedules.each do |sked|
      movies << sked.movie_id unless movies.include? sked.movie_id
      cinemas << sked.cinema_id unless cinemas.include? sked.cinema_id
    end
    
    @movies = Movie.where(id: movies)
    @cinemas = Cinema.where(id: cinemas)
    
  end
  
  # DELETE /sources/<id>.json route
  # Deletes a source.
  def destroy
    @schedule = Schedule.find(params[:id])
    @schedule.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end
  
  private
  
    def error(message, code = 400)
      resp = {status: 'error', message: message}
      render json: resp, status: code
    end

end
