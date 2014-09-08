class BackstageController < ApplicationController

  before_action :authenticate_user!

  layout 'backstage'

  def index

  end

end
