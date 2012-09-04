class ForumsController < ApplicationController
  # Render the forums home page
  def index
    @forums = Forum.all(
      :include => [:last_post],
      :order   => "ancestry ASC, display_order ASC"
    )
  end

  # Show a forum with all it's topics
  def show
    size  = 6
    page  = params[:page]      || 1
    sort  = params[:sort]      || "last_post_at"
    days  = params[:daysprune] || "-1"
    order = params[:order]     || "desc"
    
    # fetch the topics
    @topics = Topic.where(:forum_id => params[:id])
                   .includes(:user, :posts)
                   .page(page)
                   .per(size)
                   .order('sticky desc')
                   .order("#{sort} #{order}")

    @forum     = Forum.find(params[:id])
    @topicbits = []

    # loop through the topics and check permissions, visibility, etc.
    @topics.each_with_index do |topic, i|
      # check if there are new post
      if logged_in?
        if (topic.posts.last.date > topic.topic_reads.by_user(current_user.id).first.date)
          @has_new_post = true
        end
      end
      
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
