class PostsController < ApplicationController
  
  ## temp variable
  @@post_per_page   = 10
  @@report_forum_id = 10
  
  # Shows the post content on it's own page
  def show
    @post  = Post.find(params[:id])
    @topic = @post.topic

    # breadcrumbs
    add_breadcrumb "Forum", root_path
    if !@topic.forum.ancestors.empty?
      for ancestor in @topic.forum.ancestors
        add_breadcrumb ancestor.title, forum_path(ancestor)
      end
      add_breadcrumb @topic.forum.title, forum_path(@topic.forum_id)
      add_breadcrumb @topic.title, topic_path(@topic)
      add_breadcrumb @post.content.truncate(35), topic_path(@topic)
    end
  end

  # The form to post reply to a topic
  def new
    @post  = Post.new
    @topic = Topic.find(params[:topic_id])

    # include the quoted post in the post content
    if params[:quote]
      @quote        = Post.find(params[:quote])
      @post.content = "[quote][i]#{@quote.content}[/i][/quote]<br><br><br>"
    end

    # breadcrumbs
    add_breadcrumb "Forum", root_path
    if !@topic.forum.ancestors.empty?
      for ancestor in @topic.forum.ancestors
        add_breadcrumb ancestor.title, forum_path(ancestor)
      end
      add_breadcrumb @topic.forum.title, forum_path(@topic.forum_id)
      add_breadcrumb @topic.title, topic_path(@topic)
    end
  end

  # Saves a new post into the database
  def create
    @user  = User.find(current_user.id)
    @post  = @user.posts.build(params[:post])
    @topic = @post.topic
    
    # preview?
    if !params[:preview].nil?
      # breadcrumbs
      add_breadcrumb "Home", :root_path
      if !@topic.forum.ancestors.empty?
        for ancestor in @topic.forum.ancestors
          add_breadcrumb ancestor.title, forum_path(ancestor)
        end
        add_breadcrumb @topic.forum.title, forum_path(@topic.forum.id)
        add_breadcrumb @topic.title, topic_path(@topic)
      end
      render :action => "new"
    # save post
    else
      if @post.save
        redirect_to topic_path(@post.topic_id)
      end
    end
  end

  # Edit post form
  def edit
    @post  = Post.find(params[:id])
    @topic = @post.topic
    page   = 1

    # figure out which page this post is on
    @topic.posts.to_enum.with_index(1) do |post, i|
      break if post.id == @post.id
      page = page + 1 if (i % @@post_per_page) == 0
    end

    # breadcrumbs
    post_paged_url = "%s?page=%d#post%d" % [topic_path(@topic.id), page, @post.id]
    post_content   = @post.content.truncate(35)
    
    add_breadcrumb "Forum", root_path
    if !@topic.forum.ancestors.empty?
      for ancestor in @topic.forum.ancestors
        add_breadcrumb ancestor.title, forum_path(ancestor)
      end
      add_breadcrumb @topic.forum.title, forum_path(@topic.forum_id)
      add_breadcrumb @topic.title, topic_path(@topic)
      add_breadcrumb post_content, post_paged_url
    end
  end

  # Saves all post edits to the database
  def update
    @post  = Post.find(params[:id])
    @user  = @post.user
    @topic = @post.topic

    # form values
    @post.title   = params[:post][:title]
    @post.content = params[:post][:content]

    # preview?
    if !params[:preview].nil?
      # breadcrumbs
      add_breadcrumb "Home", :root_path
      if !@topic.forum.ancestors.empty?
        for ancestor in @topic.forum.ancestors
          add_breadcrumb ancestor.title, forum_path(ancestor)
        end
        add_breadcrumb @topic.forum.title, forum_path(@topic.forum.id)
        add_breadcrumb @topic.title, topic_path(@topic)
      end
      render :action => "new"
    # save post
    else
      if @post.save
        redirect_to topic_path(@post.topic_id)
      end
    end
  end

  # Reports a post by creating a new topic is the designated staff forum
  def report
    @post  = Post.find(params[:id])
    @topic = @post.topic
    page   = 1

    # figure out which page the post is on
    @topic.posts.to_enum.with_index(1) do |post, i|
      break if @post.id == @post.id
      page = page + 1 if (i % @@post_per_page) == 0
    end

    # build the post_url of the post being reported
    post_url = "%s?page=%d#post%d" % [topic_url(@topic.id), page, @post.id]

    # report form
    if params[:report].blank?
      # breadcrumbs
      add_breadcrumb "Forum", root_path
      if !@topic.forum.ancestors.empty?
        for ancestor in @topic.forum.ancestors
          add_breadcrumb ancestor.title, forum_path(ancestor)
        end
        add_breadcrumb @topic.forum.title, forum_path(@topic.forum_id)
        add_breadcrumb @topic.title, topic_path(@topic)
        add_breadcrumb @post.content.truncate(35), post_url
      end
    # send the report
    else
      # has this post been reported before?
      if @post.report_id?
        report_topic = Topic.find(@post.report_id)
      else
        report_user  = User.find(current_user.id)
        report_topic = report_user.topics.build(
          :title    => "Reported Post by %s" % current_user.username,
          :forum_id => @@report_forum_id
        )
      end

      # build the post
      report_post = report_topic.posts.build(
        :title   => report_topic.title, 
        :content => build_report_message, 
        :user_id => report_user.id
      )
      
      if report_topic.save
        # the reported post has_one report_topic
        @post.report_id = report_topic.id
        @post.save

        redirect_to post_url
      end
    end
  end

  # Administrative options for managing posts
  def manage
    # root breadcrumb
    add_breadcrumb "Home", root_path
    
    # switch between actions
    case params[:do]
      # approve or undelete posts
      when "approve", "undelete"
        params[:post_ids].each do |post_id|
          # fetch the post
          post = Post.find(post_id)

          # if this is the first post, update the topic visible field instead
          if post.id == post.topic.posts.first.id
            Topic.update(post.topic.id, :visible => 1)
          else
            if post.visible != 1
              Post.update(post.id, :visible => 1)
            end
          end
        end
        redirect_to topic_url(params[:topic_id])

      # unapprove posts
      when "unapprove"
        params[:post_ids].each do |post_id|
          # fetch the post
          post = Post.find(post_id)

          # if this is the first post, update the topic visible field instead
          if post.id == post.topic.posts.first.id
            Topic.update(post.topic.id, :visible => 0)
          else
            if post.visible != 0
              Post.update(post.id, :visible => 0)
            end
          end
          
        end
        redirect_to topic_url(params[:topic_id])

      # merge posts
      when "merge"
        @posts   = Post.find(params[:post_ids])
        @users   = User.find(@posts.map {|u| u.user_id})
        @content = @posts.map { |p| "%s" % p.content }
        render :action => :merge

      # delete
      when "delete"
        render :action => :delete
    end
  end

  # Soft / hard delete one or more posts
  def delete
    # loop through all the post_ids
    params[:delete][:post_ids].split(/, ?/).each do |post_id|
      # get the post
      post  = Post.find(post_id)
      
      # skip if this post has already been deleted
      next if post.visible == 2

      # switch between deletion types
      case params[:delete][:type]
        # preform hard deletion
        when "hard"
          # destroy the whole topic if this post is the first post
          if post.id == post.topic.posts.first.id
            post.topic.destroy
          else
            post.destroy
          end
        # preform soft deletion
        when "soft"
          # first post?
          if post.id == post.topic.posts.first.id
            Topic.update(post.topic.id, :visible => 2)
          else
            Post.update(post.id, :visible => 2)
          end
      end
    end
    
    redirect_to topic_url(params[:delete][:topic_id])
  end

  # Merges two or more post together
  def merge
    # get the post we're merging into
    dest_post = Post.find(params[:merge][:post_id])

    # if the user_id of the dest post changes, update their post counts
    if dest_post.user_id != params[:merge][:user_id]
      User.increment_counter :post_count, params[:merge][:user_id]
      User.decrement_counter :post_count, dest_post.user_id
    end
    
    # update the destination post with it's new values
    dest_post.user_id = params[:merge][:user_id]
    dest_post.content = params[:merge][:content]
    dest_post.title   = params[:merge][:title] if !params[:merge][:title].blank?
    dest_post.save
        
    total_destroyed = 0

    # delete all the other post
    params[:merge][:post_ids].split(/, ?/).each do |post_id|
      # skip if destination post
      next if dest_post.id == post_id.to_i

      # update stats & destroy the post
      post  = Post.find(post_id)
      post.user.post_count = post.user.post_count - 1
      post.user.save
      post.destroy

      # keep track of the number of deleted post
      total_destroyed = total_destroyed + 1
    end

    # update topic stats
    topic         = dest_post.topic
    topic.user_id = params[:merge][:user_id] if dest_post.id == topic.posts.first.id
    topic.replies = topic.replies - total_destroyed
    topic.save
    
    # update forum stats
    forum              = dest_post.topic.forum
    forum.post_count   = forum.post_count - total_destroyed
    forum.last_post_id = forum.recent_post.nil? ? 0 : forum.recent_post.id
    forum.save

    redirect_to topic_url(params[:merge][:topic_id])
  end
  
private
  
  def build_report_message
    message  = "[url=%s]%s[/url] has reported a post.\n\n"
    message << "Reason:[quote]%s[/quote]\n"
    message << "Post: [url=%s]%s[/url]\n"
    message << "Forum: [url=%s]%s[/url]\n\n"
    message << "Posted by: [url=%s]%s[/url]\n"
    message << "Original Content: [quote]%s[/quote]\n"
    message  = message % [user_url(current_user), current_user.username, params[:report][:reason],
                          post_url, @topic.title, forum_url(@topic.forum), (@topic.forum.title),
                          user_url(@post.user), @post.user.username, @post.content]
  end

end