class PostsController < ApplicationController
  # view a single post
  def show
    @post = Post.find(params[:id])
  end

  # post reply form
  def new
    @post = Post.new
  end

  # add post reply to topic
  def create
    @post = Post.new(
      :content  => params[:post][:content], 
      :topic_id => params[:post][:topic_id], 
      :user_id  => current_user.id
    )
    
    if @post.save
      @topic = Topic.find(@post.topic_id)
      @topic.update_attributes(
        :last_poster_id => current_user.id, 
        :last_post_at   => Time.now
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

      flash[:notice] = "Successfully created post."
      redirect_to topic_url @post.topic_id
    else
      render :action => 'new'
    end
  end

  # edit post
  def edit
    @post = Post.find(params[:id])
  end

  # update edited post
  def update
    @post = Post.find(params[:id])
    if @post.update_attributes(params[:post])
      @topic = Topic.find(@post.topic_id)
      @topic.update_attributes(
        :last_poster_id => current_user.id, 
        :last_post_at   => Time.now
      )
      redirect_to @post, :notice  => "Successfully updated post."
    else
      render :action => 'edit'
    end
  end

  # delete post
  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    @flash[:notice] = "Successfully destroyed post."
    redirect_to forums_path
  end
end
