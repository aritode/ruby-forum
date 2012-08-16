class ApplicationController < ActionController::Base
  include ControllerAuthentication
  protect_from_forgery
  
  # checks whether or not a user has permission to perform said actions
  def check_user_permissions action
    if Usergroup.find(logged_in? ? current_user.usergroup_id : 1).send(action) == false
      render "errors/permissions"
    end
  end

  # check a forums permission
  def check_forum_permissions action, forum_id
    if Forum.find(forum_id).send(action) == false
      render "errors/permissions"
    end
  end
end
