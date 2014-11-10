class SchedulesController < ApplicationController
  
  # GET /schedules.json route
  def index
    @schedules = Schedule.limit(25)
  end

end
