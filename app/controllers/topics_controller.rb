class TopicsController < ApplicationController
  # Show the topic and all post associated with it
  def show
    # grab the topic
    @topic = Topic.find(params[:id])
    
    # check if we need to redirect the user
    if @topic.redirect?
      redirect_to topic_url(@topic.redirect)
    end
    
    # get all the post
    @posts    = Post.where(:topic_id => @topic.id).page(params[:page]).per(15)
    @postbits = []
    
    # loop through the post and check permissions, visibility, etc.
    @posts.each_with_index do |post, i|
      # permissions code goes here
      @postbits[i] = post
      @postbits[i][:post_count] = (i + 1)
    end

    # breadcrumbs
    add_breadcrumb "Forum", root_path
    if !@topic.forum.ancestors.empty?
      for ancestor in @topic.forum.ancestors
        add_breadcrumb ancestor.title, forum_path(ancestor)
      end
      add_breadcrumb @topic.forum.title, forum_path(@topic.forum)
    end
    
    # update the views count
    @topic.update_attribute('views', @topic.views + 1)
  end

  # The form to start a new topic
  def new
    # check posting permissions
    check_forum_permissions :can_contain_topics, params[:forum_id]
    check_forum_permissions :allow_posting     , params[:forum_id]
    check_user_permissions  :can_post_threads

    # create a new topic object and fetch the current forum we're posting in
    @topic = Topic.new(:forum_id => params[:forum_id])
    @forum = Forum.find(@topic.forum_id)
    
    # breadcrumbs
    add_breadcrumb "Home", root_path
    if !@forum.ancestors.empty?
      for ancestor in @forum.ancestors
        add_breadcrumb ancestor.title, forum_path(ancestor)
      end
      add_breadcrumb @forum.title, forum_path(@forum.id)
    end
  end

  # Saves a new topic into the database
  def create
    # check posting permissions
    check_forum_permissions :can_contain_topics, params[:topic][:forum_id]
    check_forum_permissions :allow_posting     , params[:topic][:forum_id]
    check_user_permissions  :can_post_threads

    # preview the post
    #
    # Note: the "render :action => new" doesn't actually run any of the code in the "new" action, so
    # I'm forced to copy and paste the code from that action. This isn't ideal since it breaks the DRY
    # principle. Need to research to see if there's a better way to show post previews.
    if !params[:preview].nil?
      @topic  = Topic.new(:title => params[:topic][:title], :forum_id => params[:topic][:forum_id])
      @post   = Post.new(:content => params[:post][:content])
      @forum  = Forum.find(@topic.forum_id)

      # breadcrumbs
      add_breadcrumb "Home", root_path
      if !@forum.ancestors.empty?
        for ancestor in @forum.ancestors
          add_breadcrumb ancestor.title, forum_path(ancestor)
        end
        add_breadcrumb @forum.title, forum_path(@forum.id)
      end

      render :action => "new"

    # not a preview, create a new topic object
    else
      @topic = Topic.new(
        :title          => params[:topic][:title], 
        :forum_id       => params[:topic][:forum_id], 
        :user_id        => current_user.id,
        :last_poster_id => current_user.id,
        :last_post_at   => Time.new
      )

      # save the topic and post object into the database
      if @topic.save
        @post = Post.new(
          :content  => params[:post][:content], 
          :topic_id => @topic.id, 
          :user_id  => current_user.id
        )

        if @post.save
          @user = User.find(current_user.id)
          @user.update_attributes(
            :post_count   => @user.post_count + 1,
            :last_post_at => Time.now,
            :last_post_id => @post.id
          )

          @forum = Forum.find(@topic.forum_id)
          @forum.topic_count       = @forum.topic_count + 1
          @forum.last_post_id      = @post.id
          @forum.last_post_at      = Time.new
          @forum.last_post_user_id = current_user.id
          @forum.last_topic_id     = @topic.id
          @forum.last_topic_title  = @topic.title
          @forum.save

          redirect_to topic_path(@topic.id)
        end
      else
        render :action => 'new'
      end
    end
  end

  # Administrative options for managing topics
  def manage
    @topic_ids = params[:topic_ids].join(",") if params[:topic_ids].kind_of?(Array);
    @forums    = Forum.all(:order => "ancestry ASC, display_order ASC")
    @topics    = Topic.where(:id => @topic_ids.split(","))
    
    # root breadcrumb
    add_breadcrumb "Home", root_path
    
    # switch between actions
    case params[:do]
      # open and close topics
      when "open", "close"
        params[:topic_ids].each do |k,v|
          Topic.update(k, :open => params[:do] == 'open' ? 1 : 0)
        end
        redirect_to forum_url(params[:forum_id])

      # approve and unapprove topics
      when "approve", "unapprove"
        params[:topic_ids].each do |k,v|
          Topic.update(k, :visible => params[:do] == 'approve' ? 1 : 0)
        end
        redirect_to forum_url(params[:forum_id])

      # stick and unstick topics
      when "stick", "unstick"
        params[:topic_ids].each do |k,v|
          Topic.update(k, :sticky => params[:do] == 'stick' ? 1 : 0)
        end
        redirect_to forum_url(params[:forum_id])

      # undelete topics
      when "undelete"
        params[:topic_ids].each do |topic_id|
          # fetch the topic
          @topic = Topic.find(topic_id)
          
          # skip if this topc is already visible
          if @topic.visible == 1
            next
          end
          
          # undelete the topic
          @topic.visible = 1
          @topic.save
          
          # update forum stats
          @forum = Forum.find(@topic.forum_id)
          @forum.topic_count = @forum.topic_count + 1;
          @forum.post_count  = @forum.post_count + @topic.replies;
          
          # update last topic info
          if @forum.last_topic
            @forum.last_post_id      = @forum.last_topic.id
            @forum.last_post_at      = @forum.last_topic.last_post_at
            @forum.last_post_user_id = @forum.last_topic.last_poster_id
            @forum.last_topic_id     = @forum.last_topic.id
            @forum.last_topic_at     = @forum.last_topic.created_at
            @forum.last_topic_title  = @forum.last_topic.title
          end
          
          @forum.save
        end

        redirect_to forum_url(params[:forum_id])

      # move, merge and delete topics
      when "move"
        render :action => :move
      when "merge"
        render :action => :merge
      when "delete"
        render :action => :delete
    end
  end
  
  # Move one or more topics to a another forum with or without redirects
  def move
    @this_forum = Forum.find(params[:move][:forum_id]);
    @dest_forum = Forum.find(params[:move][:destination_forum]);
    
    # loop through all the selected topics
    params[:move][:topic_ids].split(/, ?/).each do |topic_id|
      # fetch the current topic
      @topic = Topic.find(topic_id);

      # if the user specifies, leave a dupe thread behind and use it as a redirect
      if params[:move][:redirect] != "none"
        trail          = @topic.dup
        trail.redirect = @topic.id
        trail.expires  = get_expired params[:move] if params[:move][:redirect] == "expires"
        trail.forum_id = params[:move][:forum_id]
        trail.save
      end
      
      # move the thread to the destination forum
      @topic.forum_id  = @dest_forum.id
      @topic.save

      # update the destination forum stats & info
      @dest_forum.topic_count = @dest_forum.topic_count + 1
      @dest_forum.post_count  = @dest_forum.post_count  + (@topic.posts.count - 1)
      @dest_forum.save
      
      @this_forum.topic_count = @this_forum.topic_count - 1
      @this_forum.post_count  = @this_forum.post_count  - (@topic.posts.count - 1)
      
      # check and see if we need to update the last_topic information
      if @this_forum.last_topic
        @this_forum.last_post_id      = @this_forum.last_topic.id
        @this_forum.last_post_at      = @this_forum.last_topic.last_post_at
        @this_forum.last_post_user_id = @this_forum.last_topic.last_poster_id
        @this_forum.last_topic_id     = @this_forum.last_topic.id
        @this_forum.last_topic_at     = @this_forum.last_topic.created_at
        @this_forum.last_topic_title  = @this_forum.last_topic.title
      end

      @this_forum.save
    end
    
    redirect_to forum_url(params[:move][:forum_id])
  end
  
  # Soft / hard delete one or more topics
  def delete
    # loop through all the selected topics
    params[:delete][:topic_ids].split(/, ?/).each do |topic_id|
      # fetch the current topic
      @topic = Topic.find(topic_id)

      # skip if this topic has already been deleted
      if @topic.visible == 2
        next
      end

      # destroy the topic if it's a redirect
      if @topic.redirect?
        # before we delete it, update the redirect ids for all associated topics
        items = Topic.where(:redirect => @topic.id)
        items.each do |item|
          item.redirect = @topic.redirect
          item.save
        end
        @topic.destroy
      else
        # update forum stats
        @forum = Forum.find(@topic.forum_id)
        @forum.topic_count = @forum.topic_count - 1;
        @forum.post_count  = @forum.post_count - @topic.replies;

        # check and see if we need to update the last_topic information
        if @forum.last_topic
          @forum.last_post_id      = @forum.last_topic.id
          @forum.last_post_at      = @forum.last_topic.last_post_at
          @forum.last_post_user_id = @forum.last_topic.last_poster_id
          @forum.last_topic_id     = @forum.last_topic.id
          @forum.last_topic_at     = @forum.last_topic.created_at
          @forum.last_topic_title  = @forum.last_topic.title
        end

        @forum.save
        
        # switch between delete types
        case params[:delete][:type]
          # preform hard delete
          when "hard"
            items = Topic.where(:redirect => @topic.id)
            items.each do |item|
              item.destroy
            end
            @topic.destroy
          # preform soft delete
          when "soft"
            Topic.update(@topic.id, :visible => 2)
        end
      end
    end

    redirect_to forum_url(params[:delete][:forum_id])
  end

  # Merge topics into each other
  def merge
    # fetch the destination topic
    destination_topic = Topic.find(params[:merge][:destination_topic])

    # loop through all the selected topics
    params[:merge][:topic_ids].split(/, ?/).each do |topic_id|

      # skip if this is the destination topic
      if destination_topic.id == topic_id.to_i
        next
      end

      # fetch the current_topic
      current_topic = Topic.find(topic_id)
      
      # update the destination stats
      destination_topic.views   = destination_topic.views   + current_topic.views
      destination_topic.replies = destination_topic.replies + current_topic.replies + 1
      
      # if we're adding redirects
      if params[:merge][:redirect] != "none"

        # update all post associated with the current_topic
        items = Post.where(:topic_id => current_topic.id)
        items.each do |item|
          item.topic_id = destination_topic.id
          item.save
        end
        
        # check if the redirect expires
        if params[:merge][:redirect] == "expires"
          expires_at = DateTime.new(
            params[:merge]["expires(1i)"].to_i, 
            params[:merge]["expires(2i)"].to_i, 
            params[:merge]["expires(3i)"].to_i
          )
        end
        
        # use the current_topic as a redirect
        Topic.update(current_topic.id, 
          :redirect => destination_topic.id,
          :expires  => expires_at ? expires_at : ""
        )
        
      # else if we're adding any redirects
      else
        # update all post associated with the current topic to their new destination
        items = Post.where(:topic_id => current_topic.id)
        items.each do |item|
          item.topic_id = destination_topic.id
          item.save
        end

        # destroy the current topic
        Topic.destroy(current_topic.id)
      end
    end
    
    # move destination_topic to the destination_forum
    destination_topic.forum_id = params[:merge][:destination_forum]
    destination_topic.save

    redirect_to forum_url(params[:merge][:forum_id])
  end

private
  
  def get_expired datetime
    DateTime.new(
      datetime["expires(1i)"].to_i, 
      datetime["expires(2i)"].to_i, 
      datetime["expires(3i)"].to_i
    )
  end
  
end