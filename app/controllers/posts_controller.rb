class PostsController < ApplicationController
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
        :user_id  => current_user.id
      )

      # save the post and update the users and forum stats
      if @post.save
        @topic = Topic.find(@post.topic_id)
        @topic.update_attributes(
          :last_poster_id => current_user.id, 
          :last_post_at   => Time.now,
          :replies        => @topic.replies + 1
        )

        @user = User.find(current_user.id)
        @user.update_attributes(
          :post_count   => @user.post_count + 1,
          :last_post_at => Time.now,
          :last_post_id => @post.id
        )

        @forum = Forum.find(@topic.forum_id)
        @forum.update_attributes(
          :post_count         => @forum.post_count + 1,
          :last_post_id       => @post.id,
          :last_post_at       => Time.now,
          :last_post_user_id  => current_user.id,
          :last_topic_at      => Time.now,
          :last_topic_id      => params[:post][:topic_id],
          :last_topic_title   => @topic.title
        )

        redirect_to topic_url @post.topic_id
      else
        render :action => 'new'
      end
    end
  end

  # The form to edit posts
  def edit
    @post  = Post.find(params[:id])
    @topic = Topic.find(@post.topic_id) # find the topic we're posting in

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
end
