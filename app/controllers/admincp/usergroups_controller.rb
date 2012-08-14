class Admincp::UsergroupsController < Admincp::ApplicationController

  def index
    @usergroups = Usergroup.all(:order => :title)
  end

  def show
    @usergroup = Usergroup.find(params[:id])
  end

  def new
    @usergroup = Usergroup.new
  end

  def edit
    @usergroup = Usergroup.find(params[:id])
  end

  def create
    @usergroup = Usergroup.new(params[:usergroup])

    if @usergroup.save
      redirect_to admincp_usergroup_url, :notice => "Usergroup was successfully created."
    else
      render :action => 'new'
    end
  end

  def update
    @usergroup = Usergroup.find(params[:id])

    if @usergroup.update_attributes(params[:usergroup])
      redirect_to admincp_usergroup_url, :notice => "Usergroup was successfully updated."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @usergroup = Usergroup.find(params[:id])
    @usergroup.destroy

    redirect_to admincp_usergroup_url, :notice => "Successfully destroyed usergroup."
  end
end
