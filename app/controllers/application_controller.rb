class ApplicationController < ActionController::Base
  include ControllerAuthentication
  protect_from_forgery
  
  # keep track of the user's visit times
  before_filter :update_users_last_visit
  
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

  # update the user's last visit time if it's older than an hour
  def update_users_last_visit
    if logged_in?
      if current_user.last_visit_at.nil?
        User.find(current_user.id).update_column('last_visit_at', Time.now)
      else
        if (current_user.last_visit_at + 1.hour) < Time.now 
          User.find(current_user.id).update_column('last_visit_at', Time.now)
        end
      end
    end
  end
end