class ForumsController < ApplicationController
  def index
    @forums = Forum.all(:order => "ancestry ASC, display_order ASC")
  end

  def show
    @forum  = Forum.find(params[:id])
    
    # start breadcrumbs
    add_breadcrumb "Home", :root_path
    # include all ancestor forums in breadcrumbs
    if !@forum.ancestors.empty?  
      for ancestor in @forum.ancestors
        add_breadcrumb ancestor.title, ancestor.id
      end
    end
  end
end
