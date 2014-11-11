class CinemasController < ApplicationController
  before_action :set_cinema, only: [:show, :edit, :update, :destroy]

  # GET /cinemas.json route
  # Returns all cinemas managed my Silver
  def index
    if params[:type] == 'list' && user_signed_in?
      @cinemas = Cinema.select(:id, :name).order(:name)
      render :list
    else
      @cinemas = Cinema.order(:name)
    end
  end

  # GET /cinemas/1.json route
  # Returns information about a single cinema
  def show
  end

  # PATCH/PUT /cinemas/1.json route
  # Allows cinemas to be updated with new information
  def update
    respond_to do |format|
      if @cinema.update(cinema_params)
        format.json { render :show, status: :ok, location: @cinema }
      else
        format.json { render json: @cinema.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # GET /cinemas/1/schedules.json route
  # Returns the cinema's schedules.
  #
  # TODO: allow all schedules for a specific date to be returned
  def schedules
    
    cinema = Cinema.find(params[:id])
    @schedules = cinema.schedules.scope.upcoming.select('DISTINCT ON (room) *').order(:room).includes(:movie)
    
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cinema
      @cinema = Cinema.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cinema_params
      params.require(:cinema).permit(:name, :address, :phone_number, :website, :latitude, :longitude, :status)
    end
end
