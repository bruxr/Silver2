# Controller for the /api/sources resource.
class SourcesControllerController < ApplicationController
  
  before_action :set_source, only: [:update, :source]
  
end
