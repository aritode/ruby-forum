class ForumsController < ApplicationController
  # Render the forums home page
  def index
    @forums = Forum.all(:order => "ancestry ASC, display_order ASC")
  end

  # Show a particular forum with any and all topics
  def show
    @forum  = Forum.find(params[:id])
    @topics = Topic.where(:forum_id => @forum.id).page(params[:page]).per(25).order("updated_at DESC")
    @topicbits = []
    
    # loop through the topics and check permissions, visibility, etc.
    @topics.each_with_index do |topic, i|
      @topicbits[i] = topic
    end

    # start breadcrumbs
    add_breadcrumb "Home", root_path
    if !@forum.ancestors.empty?  
      for ancestor in @forum.ancestors
        add_breadcrumb ancestor.title, forum_path(ancestor)
      end
    end
  end
end
