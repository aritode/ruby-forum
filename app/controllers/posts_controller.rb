class PostsController < ApplicationController
  # Shows the post content on it's own page
  def show
    @post = Post.find(params[:id])
  end

  # The form to post reply to a topic
  def new
    @post  = Post.new
    @topic = Topic.find(params[:topic]) # find the topic we're posting in

    # breadcrumbs
    add_breadcrumb "Forum", :root_path
    if !@topic.forum.ancestors.empty?
      for ancestor in @topic.forum.ancestors
        add_breadcrumb ancestor.title, ancestor.id
      end
      add_breadcrumb @topic.forum.title, forum_path(@topic.forum_id) # add current forum
      add_breadcrumb @topic.title, topic_path(@topic)                # add current topic
    end
  end

  # Saves post into the database
  def create
    # create the post object
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
        :post_count  => @user.post_count + 1,
        :lastpost_at => Time.now,
        :lastpost_id => @post.id
      )
      
      @forum = Forum.find(@topic.forum_id)
      @forum.update_attributes(
        :reply_count        => @forum.reply_count + 1,
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

  # The form to edit posts
  def edit
    @post  = Post.find(params[:id])
    @topic = Topic.find(@post.topic_id) # find the topic we're posting in

    # breadcrumbs
    add_breadcrumb "Forum", :root_path
    if !@topic.forum.ancestors.empty?
      for ancestor in @topic.forum.ancestors
        add_breadcrumb ancestor.title, ancestor.id
      end
      add_breadcrumb @topic.forum.title, forum_path(@topic.forum_id)    # add current forum
      add_breadcrumb @topic.title, topic_path(@topic)                   # add current topic
      add_breadcrumb @post.content.truncate(35), topic_path(@topic)     # add current post
    end

  end

  # Saves all post edits to the database
  def update
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

  # Removes posts from the database
  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    @flash[:notice] = "Successfully destroyed post."
    redirect_to forums_path
  end
end
