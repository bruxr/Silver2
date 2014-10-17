# Controller for the /api/movies resource.
class MoviesController < ApplicationController
  before_action :set_movie, only: [:show, :edit, :update, :destroy]

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

    if params[:filter].nil? || params[:filter] == 'now-showing'
      @movies = Movie.now_showing.limit(limit).offset(offset).all
    elsif params[:filter] == 'past' || params[:filter] == 'finished'
      @movies = Movie.past.limit(limit).offset(offset).all
    elsif params[:filter] == 'all'
      @movies = Movie.all.limit(limit).offset(offset).all
    else
      raise "Invalid movie filter #{params[:filter]}"
    end

  end

  # GET /movies/1
  # GET /movies/1.json
  def show
  end

  # GET /movies/new
  def new
    @movie = Movie.new
  end

  # GET /movies/1/edit
  def edit
  end

  # POST /movies
  # POST /movies.json
  def create
    @movie = Movie.new(movie_params)

    respond_to do |format|
      if @movie.save
        format.html { redirect_to @movie, notice: 'Movie was successfully created.' }
        format.json { render :show, status: :created, location: @movie }
      else
        format.html { render :new }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /movies/1
  # PATCH/PUT /movies/1.json
  def update
    respond_to do |format|
      if @movie.update(movie_params)
        format.html { redirect_to @movie, notice: 'Movie was successfully updated.' }
        format.json { render :show, status: :ok, location: @movie }
      else
        format.html { render :edit }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /movies/1
  # DELETE /movies/1.json
  def destroy
    @movie.destroy
    respond_to do |format|
      format.html { redirect_to movies_url, notice: 'Movie was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_movie
      @movie = Movie.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def movie_params
      params[:movie]
    end
end
