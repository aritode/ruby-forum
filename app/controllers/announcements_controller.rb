class AnnouncementsController < ApplicationController

  def index
    @announcements = Announcement.all

    # breadcrumbs
    add_breadcrumb "Forum", root_path
  end
  
  def show
    @announcement = Announcement.find(params[:id])

    # breadcrumbs
    add_breadcrumb "Forum", root_path
    if !@announcement.forum.ancestors.empty?
      for ancestor in @announcement.forum.ancestors
        add_breadcrumb ancestor.title, forum_path(ancestor)
      end
      add_breadcrumb @announcement.forum.title, forum_path(@announcement.forum_id)
    end

    # update the views count
    @announcement.update_attribute('views', @announcement.views + 1)
  end

  def new
    @announcement = Announcement.new
    @forums       = Forum.all(:order => "ancestry ASC, display_order ASC")

    # breadcrumbs
    add_breadcrumb "Forum", root_path
  end

  def create
    @announcement = Announcement.new(params[:announcement])
    @forums       = Forum.all(:order => "ancestry ASC, display_order ASC")

    if @announcement.save
      redirect_to @announcement, :notice => "Successfully created announcement."
    else
      render :action => 'new'
    end
  end

  def edit
    @announcement = Announcement.find(params[:id])
    @forums       = Forum.all(:order => "ancestry ASC, display_order ASC")

    # breadcrumbs
    add_breadcrumb "Forum", root_path
    if !@announcement.forum.ancestors.empty?
      for ancestor in @announcement.forum.ancestors
        add_breadcrumb ancestor.title, forum_path(ancestor)
      end
      add_breadcrumb @announcement.forum.title, forum_path(@announcement.forum_id)
      add_breadcrumb @announcement.title, announcement_path(@announcement)
    end
  end

  def update
    @announcement = Announcement.find(params[:id])
    @forums       = Forum.all(:order => "ancestry ASC, display_order ASC")

    if @announcement.update_attributes(params[:announcement])
      redirect_to @announcement, :notice  => "Successfully updated announcement."
    else
      # breadcrumbs
      add_breadcrumb "Forum", root_path
      if !@announcement.forum.ancestors.empty?
        for ancestor in @announcement.forum.ancestors
          add_breadcrumb ancestor.title, forum_path(ancestor)
        end
        add_breadcrumb @announcement.forum.title, forum_path(@announcement.forum_id)
        add_breadcrumb @announcement.title, announcement_path(@announcement)
      end

      render :action => 'edit'
    end
  end

  def destroy
    @announcement = Announcement.find(params[:id])
    @announcement.destroy
    redirect_to announcements_url, :notice => "Successfully destroyed announcement."
  end

end