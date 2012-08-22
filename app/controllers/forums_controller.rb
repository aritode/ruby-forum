class ForumsController < ApplicationController
  def index
    @forums = Forum.all(:order => "ancestry ASC, display_order ASC")
  end

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
    # include all ancestor forums in breadcrumbs
    if !@forum.ancestors.empty?  
      for ancestor in @forum.ancestors
        add_breadcrumb ancestor.title, forum_path(ancestor)
      end
    end
  end
end
