class TopicsController < ApplicationController
  # Show the topic and all post associated with it
  def show
    @posts = [] # for the postbits
    @topic = Topic.find(params[:id])
    @topic.update_attribute('views', @topic.views + 1)
    
    # loop through the post and check permissions, visibility, etc.
    @topic.posts.each_with_index do |post, i|
      @posts[i] = post
      @posts[i][:post_count] = i + 1
    end

    # breadcrumbs
    add_breadcrumb "Forum", :root_path
    if !@topic.forum.ancestors.empty? # include any ancestor forums
      for ancestor in @topic.forum.ancestors
        add_breadcrumb ancestor.title, ancestor.id
      end
      add_breadcrumb @topic.forum.title, :forum_path # add the current forum
    end
    
  end

  # The form to start a new topic
  def new
    # check posting permissions
    check_forum_permissions :can_contain_topics, params[:forum]
    check_forum_permissions :allow_posting     , params[:forum]
    check_user_permissions  :can_post_threads

    # create a new topic object and fetch the current forum we're posting in
    @topic = Topic.new
    @forum = Forum.find(params[:forum])
    
    # breadcrumbs
    add_breadcrumb "Home", :root_path
    if !@forum.ancestors.empty? # include any ancestor forums
      for ancestor in @forum.ancestors
        add_breadcrumb ancestor.title, ancestor.id
      end
    end
  end

  # Saves a new topic into the database
  def create
    # check posting permissions
    check_forum_permissions :can_contain_topics, params[:topic][:forum_id]
    check_forum_permissions :allow_posting     , params[:topic][:forum_id]
    check_user_permissions  :can_post_threads

    # create the topic object
    @topic = Topic.new(
      :title          => params[:topic][:title], 
      :last_poster_id => current_user.id,
      :last_post_at   => Time.new,
      :forum_id       => params[:topic][:forum_id], 
      :user_id        => current_user.id
    )
    
    # save the topic and post object into the database
    if @topic.save
      @post = Post.new(
        :content  => params[:post][:content], 
        :topic_id => @topic.id, 
        :user_id  => current_user.id
      )
      
      if @post.save
        flash[:notice] = "Successfully created topic."
        redirect_to "/forums/#{@topic.forum_id}"
      else
        render :action => 'new'
      end
    else
      render :action => 'new'
    end
  end

  # Removes topics from the database
  def destroy
    # check deleting permissions
    check_user_permissions :can_delete_own_threads if !is_admin?
    
    @topic = Topic.find(params[:id])
    @topic.destroy
    redirect_to topics_url, :notice => "Successfully destroyed topic."
  end
end
