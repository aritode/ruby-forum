class ForumsController < ApplicationController
  # Render the forums home page
  def index
    @forums = Forum.all(:order => "ancestry ASC, display_order ASC")
  end

  # Show a forum with all it's topics
  def show
    size  = 25
    page  = params[:page]      || 1
    sort  = params[:sort]      || "updated_at"
    days  = params[:daysprune] || 0
    order = params[:order]     || "desc"
    
    # fetch the topics
    @topics = Topic.where(:forum_id => params[:id])
                   .joins(:user)
                   .page(page)
                   .per(size)
                   .order("#{sort} #{order}")

    @forum     = Forum.find(params[:id])
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
