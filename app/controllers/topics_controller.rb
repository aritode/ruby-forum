class TopicsController < ApplicationController
  
  ## temp variable
  @@post_per_page = 10
  
  # Show the topic and all post associated with it
  def show
    @topic = Topic.find(params[:id])
    
    # check if we need to redirect the user
    if @topic.redirect?
      redirect_to topic_url(@topic.redirect)
    end
    
    # get all the post
    @posts        = Post.where(:topic_id => @topic.id).page(params[:page]).per(@@post_per_page)
    @postbits     = []
    params[:page] = params[:page] ? params[:page] : 1
    
    # loop through the post and check permissions, visibility, etc.
    @posts.each_with_index do |post, i|
      # permissions code goes here
      @postbits[i] = post
      @postbits[i][:post_count] = @@post_per_page * params[:page].to_i + i - @@post_per_page + 1
      
    end
    
    # breadcrumbs
    add_breadcrumb "Forum", root_path
    if !@topic.forum.ancestors.empty?
      for ancestor in @topic.forum.ancestors
        add_breadcrumb ancestor.title, forum_path(ancestor)
      end
      add_breadcrumb @topic.forum.title, forum_path(@topic.forum)
    end
    
    if logged_in?
      @last_read = @topic.topic_reads.by_user(current_user.id).first
      mark_topic_as_read @topic, @posts.last.date
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
    
    # previewing...
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
      
    # actual submission
    else
      @topic = Topic.new(
        :title        => params[:topic][:title], 
        :forum_id     => params[:topic][:forum_id], 
        :user_id      => current_user.id,
        :last_post_at => Time.new
      )

      if @topic.save
        @post = Post.new(
          :content  => params[:post][:content], 
          :topic_id => @topic.id, 
          :user_id  => current_user.id,
          :date     => Time.new
        )

        if @post.save
          @user = User.find(current_user.id)
          @user.update_attributes(
            :post_count   => @user.post_count + 1,
            :last_post_at => Time.now,
            :last_post_id => @post.id
          )

          @forum = Forum.find(@topic.forum_id)
          @forum.topic_count  = @forum.topic_count + 1
          @forum.last_post_id = @forum.recent_post.nil? ? 0 : @forum.recent_post.id
          @forum.save

          mark_topic_as_read @topic, @post.date

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
          
          # skip if this topic is already visible
          if @topic.visible == 1
            next
          end
          
          # undelete the topic
          @topic.visible = 1
          @topic.save
          
          # update forum stats
          @forum = Forum.find(@topic.forum_id)
          @forum.topic_count  = @forum.topic_count + 1;
          @forum.post_count   = @forum.post_count + @topic.replies;
          @forum.last_post_id = @forum.recent_post.nil? ? 0 : @forum.recent_post.id
          @forum.save
        end
        redirect_to forum_url(params[:forum_id])

      # unapprove topics
      when "unapprove"
        params[:topic_ids].each do |topic_id|
          # fetch the topic
          @topic = Topic.find(topic_id)
          
          # skip if this topic is already unapproved
          if @topic.visible == 0
            next
          end
          
          # unapprove the topic
          @topic.visible = 0
          @topic.save
          
          # update forum stats
          @forum = Forum.find(@topic.forum_id)
          @forum.topic_count  = @forum.topic_count - 1;
          @forum.post_count   = @forum.post_count - @topic.replies;
          @forum.last_post_id = @forum.recent_post.nil? ? 0 : @forum.recent_post.id
          @forum.save
        end
        redirect_to forum_url(params[:forum_id])

      # approve topics
      when "approve"
        params[:topic_ids].each do |topic_id|
          # fetch the topic
          @topic = Topic.find(topic_id)
          
          # skip if this topic is already approved
          if @topic.visible == 1
            next
          end
          
          # approve the topic
          @topic.visible = 1
          @topic.save
          
          # update forum stats
          @forum = Forum.find(@topic.forum_id)
          @forum.topic_count  = @forum.topic_count + 1;
          @forum.post_count   = @forum.post_count + @topic.replies;
          @forum.last_post_id = @forum.recent_post.nil? ? 0 : @forum.recent_post.id
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
  
  # Move one or more topics to a another forum with or without trailing redirects
  def move
    params[:move][:topic_ids].split(/, ?/).each do |topic_id|
      # leave a dupe thread behind and use it as a redirect
      if params[:move][:redirect] != "none"
        trail          = Topic.find(topic_id).dup
        trail.redirect = topic_id
        trail.expires  = get_expired params[:move] if params[:move][:redirect] == "expires"
        trail.forum_id = params[:move][:forum_id]
        trail.save
      end
      
      move_topic topic_id, params[:move][:destination_forum]
    end
    
    redirect_to forum_url(params[:move][:forum_id])
  end
  
  # Soft / hard delete one or more topics
  def delete
    params[:delete][:topic_ids].split(/, ?/).each do |topic_id|
      # fetch the topic and save the replies and forum_id for later use
      @topic   = Topic.find(topic_id)
      replies  = @topic.replies
      forum_id = @topic.forum_id

      # skip if this topic has already been deleted
      if @topic.visible == 2
        next
      end

      # just destroy the topic if it's a redirect
      if @topic.redirect?
        # before we delete it, update the redirect ids for all associated topics
        items = Topic.where(:redirect => @topic.id)
        items.each do |item|
          item.redirect = @topic.redirect
          item.save
        end
        @topic.destroy
      else
        # switch between delete types
        case params[:delete][:type]
          # preform a hard delete
          when "hard"
            items = Topic.where(:redirect => @topic.id)
            items.each do |item|
              item.destroy
            end
            @topic.destroy
          # preform a soft delete
          when "soft"
            Topic.update(@topic.id, :visible => 2)
        end

        # update the forum stats
        @forum = Forum.find(forum_id)
        @forum.topic_count  = @forum.topic_count - 1;
        @forum.post_count   = @forum.post_count  - replies
        @forum.last_post_id = @forum.recent_post.nil? ? 0 : @forum.recent_post.id
        @forum.save
      end
    end

    redirect_to forum_url(params[:delete][:forum_id])
  end

  # Merge two or more topics into each other
  def merge
    @dest_topic = Topic.find(params[:merge][:destination_topic])

    # loop through all the selected topics
    params[:merge][:topic_ids].split(/, ?/).each do |topic_id|
      # skip if this is the destination topic
      if @dest_topic.id == topic_id.to_i
        next
      end

      @topic = Topic.find(topic_id)
      @posts = Post.where(:topic_id => @topic.id)

      # update all post to their new topic destination
      @posts.each do |item|
        item.topic_id = @dest_topic.id
        item.save
      end
      
      # update the dest topic stats
      @dest_topic.views           = @dest_topic.views + @topic.views
      @dest_topic.replies         = @dest_topic.replies + @topic.replies + 1
      @dest_topic.last_post_at    = @posts.last.date
      @dest_topic.last_poster_id  = @posts.last.user_id
      @dest_topic.save

      # update current forum stats
      @this_forum = Forum.find(params[:merge][:forum_id]);
      @this_forum.topic_count  = @this_forum.topic_count - 1
      @this_forum.post_count   = @this_forum.post_count  + 1
      @this_forum.last_post_id = @this_forum.recent_post.nil? ? 0 : @this_forum.recent_post.id
      @this_forum.save

      # if we're leaving a redirect, use the current topic instead of creating a new one
      if params[:merge][:redirect] != "none"
        @topic.redirect = @dest_topic.id
        @topic.expires  = get_expired params[:merge] if params[:merge][:redirect] == "expires"
        @topic.save
      else
        @topic.destroy
      end
    end

    # move destination topic to the destination forum
    move_topic @dest_topic.id, params[:merge][:destination_forum]

    # redirect the user back to the forums
    redirect_to forum_url(params[:merge][:forum_id])
  end
  
  # Redirect the user to the first new post in the topic
  def firstnew
    if logged_in?
      @topic       = Topic.find(params[:id])
      last_read    = @topic.topic_reads.by_user(current_user.id)
      first_unread = @topic.posts.where(["date > ?", last_read.first.date]).first if !last_read.empty?
      page         = 1

      # figure out which page the first unread post is on
      if first_unread
        if (@topic.replies + 1) > @@post_per_page
          @topic.posts.to_enum.with_index(1) do |post, i|
            break if post.id == first_unread.id
            page = page + 1 if (i % @@post_per_page) == 0
          end
        end
        
        topic_path = "#{topic_path(@topic.id)}?page=#{page}#post#{first_unread.id}"
      end
    end

    redirect_to topic_path ? topic_path : topic_path(@topic.id)
  end
  
  # Redirect the the user to the last post in the topic
  def lastpost
    @topic    = Topic.find(params[:id])
    last_post = @topic.posts.last
    page      = 1

    @topic.posts.to_enum.with_index(1) do |post, i|
      break if post.id == last_post.id
      page = page + 1 if (i % @@post_per_page) == 0
    end
    
    redirect_to "#{topic_path(@topic.id)}?page=#{page}#post#{last_post.id}"
  end
  
private

  # converts the submitted datetime params into a DateTime object
  def get_expired datetime
    DateTime.new(
      datetime["expires(1i)"].to_i, 
      datetime["expires(2i)"].to_i, 
      datetime["expires(3i)"].to_i
    )
  end

  # moves a topic to a different forum and updates the forum stats & last topic info accordingly
  def move_topic topic_id, dest_forum_id
    @topic        = Topic.find(topic_id)
    this_forum_id = @topic.forum_id # keep a record of the forum the topic used to reside in

    # return false if already in dest forum
    if this_forum_id == dest_forum_id.to_i
      return false
    end
    
    # update the topic's forum_id
    @topic.forum_id = dest_forum_id
    @topic.save

    # update the current & destination forum stats if the topic is visible
    if @topic.visible == 1
      @this_forum = Forum.find(this_forum_id)
      @this_forum.topic_count  = @this_forum.topic_count - 1
      @this_forum.post_count   = @this_forum.post_count  - @topic.replies
      @this_forum.last_post_id = @this_forum.recent_post.nil? ? 0 : @this_forum.recent_post.id
      @this_forum.save

      @dest_forum = Forum.find(dest_forum_id)
      @dest_forum.topic_count  = @dest_forum.topic_count + 1
      @dest_forum.post_count   = @dest_forum.post_count + @topic.replies
      @dest_forum.last_post_id = @dest_forum.recent_post.nil? ? 0 : @dest_forum.recent_post.id
      @dest_forum.save
      
      # if there are any parent forums, update the last_post_id for them as well
      if !@dest_forum.ancestors.empty?  
        for ancestor in @dest_forum.ancestors
          ancestor.last_post_id = ancestor.recent_post.nil? ? 0 : ancestor.recent_post.id
          ancestor.save
        end
      end
    end
  end

  # This function will check if the topic's last post is older than the configured timeout setting 
  # (typically 3 days). If the last post made is older than said days, the topic will automatically be
  # considered as read. 
  #
  # If topic has post made earlier than three days, then we store the date of the last post on the 
  # current page in the "topic_reads" table to keep track of users who read said post. Every time the
  # user loads a page of post, the last post date will be saved and those post will be marked as 
  # "read" too. This will allow us to show users new post in topics that they haven't seen yet.
  def mark_topic_as_read topic, datetime
    last_post = topic.posts.last
    last_read = topic.topic_reads.by_user(current_user.id)

    # skip if last post is older than 3 days
    if !((last_post.date + 3.days) < Time.now)
      # check if the last post on the current page is older than 3 days
      if !((datetime + 3.days) < Time.now)
        # first time reading these post, create a new row marking them as read
        if last_read.empty?
          TopicRead.new(:topic_id => topic.id, 
                        :user_id  => current_user.id, 
                        :date     => datetime).save
        else
          # check if the last post date is newer then what we have saved, if so, update the read date
          if (datetime > last_read.first.date)
            @topic_read      = TopicRead.find_by_topic_id_and_user_id(@topic.id, current_user.id)
            @topic_read.date = datetime
            @topic_read.save
          end
        end
      end
    end
  end

end