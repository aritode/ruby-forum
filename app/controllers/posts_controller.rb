class PostsController < ApplicationController
  
  ## temp variable
  @@post_per_page   = 10
  @@report_forum_id = 10
  
  # Shows the post content on it's own page
  def show
    @post  = Post.find(params[:id])
    @topic = Topic.find(@post.topic_id)

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
    # preview the post
    #
    # Note: the "render :action => new" doesn't actually run any of the code in the "new" action, so
    # I'm forced to copy and paste the code from that action. This isn't ideal since it breaks the DRY
    # principle. Need to research to see if there's a better way to show post previews.
    if !params[:preview].nil?
      @post  = Post.new
      @topic = Topic.find(params[:post][:topic_id])
      @post.content = params[:post][:content]
      
      # breadcrumbs
      add_breadcrumb "Forum", root_path
      if !@topic.forum.ancestors.empty?
        for ancestor in @topic.forum.ancestors
          add_breadcrumb ancestor.title, forum_path(ancestor)
        end
        add_breadcrumb @topic.forum.title, forum_path(@topic.forum_id)
        add_breadcrumb @topic.title, topic_path(@topic)
      end

      render :action => "new"

    # not a preview, create a new post object
    else
      @post = Post.new(
        :content  => params[:post][:content], 
        :topic_id => params[:post][:topic_id], 
        :user_id  => current_user.id,
        :date     => Time.now
      )

      # save the post and update the users and forum stats
      if @post.save
        @topic = Topic.find(@post.topic_id)
        @topic.update_attributes(
          :last_post_at => Time.now,
          :replies      => @topic.replies + 1
        )

        @user = User.find(current_user.id)
        @user.update_attributes(
          :post_count   => @user.post_count + 1,
          :last_post_at => Time.now,
          :last_post_id => @post.id
        )

        @forum = Forum.find(@topic.forum_id)
        @forum.post_count   = @forum.post_count + 1
        @forum.last_post_id = @forum.recent_post.nil? ? 0 : @forum.recent_post.id
        @forum.save

        # figure out which page this post is on
        page      = 1
        last_post = @topic.posts.last

        @topic.posts.to_enum.with_index(1) do |post, i|
          break if post.id == last_post.id
          page = page + 1 if (i % @@post_per_page) == 0
        end

        redirect_to "#{topic_path(@topic.id)}?page=#{page}#post#{last_post.id}"
      else
        render :action => 'new'
      end
    end
  end

  # The form to edit posts
  def edit
    @post  = Post.find(params[:id])
    @topic = Topic.find(@post.topic_id) # find the topic we're posting in
    page   = 1

    # figure out which page this post is on
    @topic.posts.to_enum.with_index(1) do |post, i|
      break if post.id == @post.id
      page = page + 1 if (i % @@post_per_page) == 0
    end

    # breadcrumbs
    add_breadcrumb "Forum", root_path
    if !@topic.forum.ancestors.empty?
      for ancestor in @topic.forum.ancestors
        add_breadcrumb ancestor.title, forum_path(ancestor)
      end
      add_breadcrumb @topic.forum.title, forum_path(@topic.forum_id)
      add_breadcrumb @topic.title, topic_path(@topic)
      add_breadcrumb @post.content.truncate(35), "#{topic_path(@topic.id)}?page=#{page}#post#{@post.id}"
    end
  end

  # Saves all post edits to the database
  def update
    # preview the post
    #
    # Note: the "render :action => new" doesn't actually run any of the code in the "new" action, so
    # I'm forced to copy and paste the code from that action. This isn't ideal since it breaks the DRY
    # principle. Need to research to see if there's a better way to show post previews.
    if !params[:preview].nil?
      @post  = Post.new
      @topic = Topic.find(params[:post][:topic_id])
      @post.content = params[:post][:content]
      
      # breadcrumbs
      add_breadcrumb "Forum", root_path
      if !@topic.forum.ancestors.empty?
        for ancestor in @topic.forum.ancestors
          add_breadcrumb ancestor.title, forum_path(ancestor)
        end
        add_breadcrumb @topic.forum.title, forum_path(@topic.forum_id)
        add_breadcrumb @topic.title, topic_path(@topic)
      end

      render :action => "new"
    # not a preview, update the post
    else
      @post = Post.find(params[:id])
      if @post.update_attributes(params[:post])
        @topic = Topic.find(@post.topic_id)
        @topic.update_attributes(
          :last_poster_id => current_user.id, 
          :last_post_at   => Time.now
        )
        redirect_to topic_path(@post.topic_id)
      else
        render :action => 'edit'
      end
    end
  end

  # Removes posts from the database
  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    @flash[:notice] = "Successfully destroyed post."
    redirect_to forums_path
  end

  # Reports a post by creating a new topic is the designated staff forum
  def report
    @post  = Post.find(params[:id])
    @topic = Topic.find(@post.topic_id)
    page   = 1

    # build the post_url of the post being reported
    post_url = "%s?page=%d#post%d" % [topic_url(@topic.id), page, @post.id]

    # figure out which page the post is on
    @topic.posts.to_enum.with_index(1) do |post, i|
      break if @post.id == @post.id
      page = page + 1 if (i % @@post_per_page) == 0
    end

    # render the report form
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
      # this post has been reported before, build that topic
      if @post.report_id?
        report_topic         = Topic.find(@post.report_id)
        report_topic.replies = report_topic.replies + 1
      # this is a new report, create a new topic
      else
        report_topic          = Topic.new
        report_topic.title    = "Reported Post by %s" % current_user.username
        report_topic.user_id  = current_user.id
        report_topic.forum_id = @@report_forum_id
      end
      
      # update the last post time to now
      report_topic.last_post_at = Time.now

      # save the report topic
      if report_topic.save
        # build the report content for the new post
        message  = "[url=%s]%s[/url] has reported a post.\n\n"
        message << "Reason:[quote]%s[/quote]\n"
        message << "Post: [url=%s]%s[/url]\n"
        message << "Forum: [url=%s]%s[/url]\n\n"
        message << "Posted by: [url=%s]%s[/url]\n"
        message << "Original Content: [quote]%s[/quote]\n"
        message  = message % [user_url(current_user), current_user.username, params[:report][:reason],
                              post_url, @topic.title, forum_url(@topic.forum), (@topic.forum.title),
                              user_url(@post.user), @post.user.username, @post.content]

        # create the new post 
        report_post = Post.new(
          :content   => message, 
          :topic_id  => report_topic.id? ? report_topic.id : @post.report_id, 
          :user_id   => current_user.id,
          :date      => Time.new,
        ).save

        # update the forum stats
        forum = Forum.find(report_topic.forum_id)
        forum.topic_count  = forum.topic_count + 1 if !@post.report_id?
        forum.post_count   = forum.post_count  + 1 if  @post.report_id?
        forum.last_post_id = forum.recent_post.nil? ? 0 : forum.recent_post.id
        forum.save

        # mark the reported post as reported
        @post.report_id = report_topic.id
        @post.save

        redirect_to post_url
      end
    end
  end
end
