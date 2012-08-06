class Admincp::ApplicationController < ApplicationController
  protect_from_forgery
  
  # set the admincp's default layout path
  layout "admincp/layouts/application"

  
end
