class ForumsController < ApplicationController
  def index
    @forums = Forum.all(:order => "ancestry ASC, display_order ASC")
  end

  def show
    @forum  = Forum.find(params[:id])
  end

end
