class Admincp::ForumsController < Admincp::ApplicationController

  # /admincp/forums
  def index
    @forums = Forum.all(:order => "ancestry ASC, display_order ASC")
  end
  
  # /admincp/forums/new
  def new
    @forum  = Forum.new(:parent_id => params[:parent_id])
    @forums = Forum.all(:order => "ancestry ASC, display_order ASC")
  end

  # /admincp/forums/create
  def create
    params[:forum][:parent_id] = params[:parent_id]
    @forum  = Forum.new(params[:forum])
    
    if @forum.save
      build_forum_cache
      redirect_to admincp_forum_url, :notice => "Successfully created forum."
    else
      render :action => 'new'
    end
  end

  # /admincp/forums/order
  def order
    params[:order].each do | forum_id, display_order |
      Forum.update(forum_id, :display_order => display_order)
    end

    build_forum_cache
    redirect_to admincp_forum_url, :notice => "Display order updated successfully."
  end

  # /admincp/forums/:id/edit
  def edit
    @forum  = Forum.find(params[:id])
    @forums = Forum.all(:order => "ancestry ASC, display_order ASC")
  end

  # /admincp/forums/:id/edit
  def update
    @forum = Forum.find(params[:id])
    params[:forum][:parent_id]  = params[:parent_id]
    params[:forum][:child_list] = @forum.descendant_ids.join('/')
    
    if @forum.update_attributes(params[:forum])
      build_forum_cache
      redirect_to admincp_forum_url, :notice => "Successfully updated forum."
    else
      render :action => 'edit'
    end
  end

  # /admincp/forums/:id/remove
  def remove
    @forum = Forum.find(params[:id])
  end
  
  # /admincp/forums/destroy
  def destroy
    @forum = Forum.find(params[:id])
    @forum.destroy
    build_forum_cache
    redirect_to admincp_forum_url, :notice => "Successfully destroyed forum."
  end

private
  #
  def build_forum_cache
    forums  = {}

    # update child_list
    Forum.all().each do |forum|
      forum.child_list = forum.child_ids.join('/') 
      forum.save
    end

    parents = Forum.all(
      :conditions => "ancestry is null",
      :order      => "ancestry ASC, display_order ASC"
    )

    parents.each do |parent|
      forums = forums.merge({parent => parent.descendants.arrange(:order => :display_order)})
    end

    Rails.cache.write 'forums', forums
  end

end
