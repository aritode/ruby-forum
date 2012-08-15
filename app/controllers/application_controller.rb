class ApplicationController < ActionController::Base
  include ControllerAuthentication
  protect_from_forgery
  
  # renders a no permissions error page
  def render_no_permissions
   render "errors/permissions"
  end
  
end
