# Controller for the /api/movies resource.
class MoviesController < ApplicationController
  before_action :set_movie, only: [:show, :update, :destroy]

  # The /movies index route.
  #
  # Filtering:
  # -> /movies.json?filter=now-showing
  # The API supports filters that will return a subset of
  # movies that fit the filter:
  # now-showing      -> movies that has upcoming schedules (default)
  # finished or past -> inverse of now-showing, movies without any upcoming skeds.
  # all              -> all movies
  #
  # This API endpoint will only return a maximum of 25 movies, add an
  # offset (/movies.json?offset=25) to paginate results.
  def index

    offset = 0
    offset = params[:offset].to_i if params[:offset] =~ /\A\d+\Z/ && params[:offset] >= 0
    limit = 25
    
    if params[:type] == 'list' && user_signed_in?
    
      @movies = Movie.select('id,title').order('title')
      render :list
    
    else
      
      @schedules_filter = :upcoming

      if params[:filter].nil? || params[:filter] == 'now-showing'
        @movies = Movie.now_showing.limit(limit).offset(offset).all
      elsif params[:filter] == 'past' || params[:filter] == 'finished'
        @movies = Movie.past.limit(limit).offset(offset).all
      elsif params[:filter] == 'all'
        @schedules_filter = :all
        @movies = Movie.all.limit(limit).offset(offset).all
      else
        raise "Invalid movie filter #{params[:filter]}"
      end
      
    end

  end

  # The movies/<id> route.
  # Returns information about a single movie.
  def show
  end

  # The POST /movies.json route
  # Creating movies is not supported by Silver.
  def create
    not_found
  end

  # PATCH/PUT /movies/<id>.json route
  # Updates a movie's details
  def update
    respond_to do |format|
      if @movie.update(movie_params)
        format.json { render :show, status: :ok, location: @movie }
      else
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /movies/<id>.json route
  # Deleting movies is not allowed.
  def destroy
    not_found
  end
  
  # POST /movies/<id>/update_scores.json route
  # Updates the movie's scores.
  def update_scores
    UpdateSingleMovieScoresJob.perform_async(params[:id])
    resp = {status: 'ok', date: Time.zone.now }
    respond_to do |format|
      format.json { render json: resp }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_movie
      @movie = Movie.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def movie_params
      params.require(:movie).permit(:title, :overview, :tagline, :website, :trailer, :runtime, :mtrcb_rating, :release_date)
    end
end
