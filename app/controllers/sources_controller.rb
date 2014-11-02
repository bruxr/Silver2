# Controller for the /api/sources resource.
class SourcesControllerController < ApplicationController
  
  before_action :set_source, only: [:update, :destroy]
  
  # PATCH/PUT /sources/<id>.json route
  # Updates a source's info.
  def update
    respond_to do |format|
      if @source.update(source_params)
        format.json { render :show, status: :ok, location: @source }
      else
        format.json { render json: @source.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # DELETE /sources/<id>.json route
  # Deletes a source.
  def destroy
    @source.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end
  
  private
  
    def set_source
      @source = Source.find(params[:id])
    end
    
    def source_params
      params.require(:source)
    end
  
end
