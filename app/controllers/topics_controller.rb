class TopicsController < ApplicationController
  def show
    @topic = Topic.find(params[:id])
  end

  def new
    check_permissions :can_post_threads

    @topic = Topic.new
  end

  def create
    check_permissions :can_post_threads

    # create the topic
    @topic = Topic.new(
      :name           => params[:topic][:name], 
      :last_poster_id => current_user.id,
      :last_post_at   => Time.new,
      :forum_id       => params[:topic][:forum_id], 
      :user_id        => current_user.id
    )
    
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

  def destroy
    check_permissions :can_delete_own_posts

    @topic = Topic.find(params[:id])
    @topic.destroy
    redirect_to topics_url, :notice => "Successfully destroyed topic."
  end
end
