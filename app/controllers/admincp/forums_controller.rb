class Admincp::ForumsController < Admincp::ApplicationController

  def index
    @forums = Forum.all(:order => "ancestry ASC, display_order ASC")
  end
  
  def new
    @forum  = Forum.new(:parent_id => params[:parent_id])
    @forums = Forum.all(:order => "ancestry ASC, display_order ASC")
  end

  def create
    params[:forum][:parent_id] = params[:parent_id]
    @forum = Forum.new(params[:forum])
    @forums = Forum.all(:order => "ancestry ASC, display_order ASC")
    if @forum.save
      redirect_to admincp_forum_url, :notice => "Successfully created forum."
    else
      render :action => 'new'
    end
  end

  # updates the display order for all the forums via the forums manager page
  def order
    params[:order].each do | forum_id, display_order |
      Forum.update(forum_id, :display_order => display_order)
    end
    
    redirect_to admincp_forum_url, :notice => "Display order updated successfully."
  end

  def edit
    @forum  = Forum.find(params[:id])
    @forums = Forum.all(:order => "ancestry ASC, display_order ASC")
  end

  def update
    @forum = Forum.find(params[:id])
    params[:forum][:parent_id] = params[:parent_id]
    
    if @forum.update_attributes(params[:forum])
      redirect_to admincp_forum_url, :notice => "Successfully updated forum."
    else
      render :action => 'edit'
    end
  end

  def remove
    @forum = Forum.find(params[:id])
  end
  
  def destroy
    @forum = Forum.find(params[:id])
    @forum.destroy
    redirect_to admincp_forum_url, :notice => "Successfully destroyed forum."
  end
  

end
