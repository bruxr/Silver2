class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  # Add a short 3 second sleep for simulating slow
  # responses in the internet
  before_action do
    #sleep 3 if Rails.env.development?
  end
  
  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end
  
end
