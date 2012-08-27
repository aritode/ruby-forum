module ForumsHelper
  # Builds an array of forum data based on the ids and collection info passed
  #
  # @parm Array   The array of forum ids to build
  # @parm Array   An Array of all the forums present in the database (avoids querying the db)
  def build_child_info(ids, collection)
    forums = []
    for forum in collection
      if ids.include?(forum.id)
          forums.push(forum)
      end
    end
    return forums
  end

  # Recursive function to render all child forums for a parent forum in the forums index & show page.
  #
  # @parm Hash    The nested hash of child forums
  # @parm String  The HTML that will be rendered when finished
  def render_child_forums(forum, html = "")
    forum.each do |key, val|
      break if key.depth >= 2 # break iteration after max_depth is reach
      html << render(:partial => "level#{key.depth}_post", :locals => {:child => key})
      if !val.empty?
        render_child_forums(val, html)
      end
    end

    return raw html
  end
  
  # Returns true if you're at the forums home page. I use this for constructing breadcrumbs mostly,
  # but could be useful for layouts & structuring pages, ads, etc.
  #
  # @return Boolean   Returns true if a visitor is at the forums home page.
  def is_forum_home?
    params[:controller] == 'forums' && params[:action] == 'index'
  end
  
  # Constructs a link with a list of sorting paramters for the threads list
  #
  # @parm String   The linked text
  # @parm String   The name of the sort field to sort by (e.g. lastpost, views, etc)
  def build_sort_link(text, sort)
    link_to(text, :sort => sort, 
      :order      => params[:order]     == 'desc' ? 'asc' : 'desc', 
      :page       => params[:page]      ||= 1, 
      :daysprune  => params[:daysprune] ||= -1
    )
  end
  
  # Repeats a character x amount of times to give forums their proper depth position in the tree.
  #
  # @parm Integer The number of times to repeat the character
  # @parm String  The actual character to use
  def depth_char(depth, depth_char = "--")
    char = ""
    depth.times do |d|
      char << depth_char
    end
    return char
  end

  # Recursive function to render all child forums for a parent forum in the forums manager index.
  #
  # @parm Hash    The nested hash of child forums
  # @parm String  The HTML that will be rendered when finished
  def render_admincp_child_forums(hash, html = "")
    hash.each do |key, val|
      html << render(:partial => 'forum', :locals => {:forum => key})
      if !val.empty?
        render_admincp_child_forums(val, html)
      end
    end

    return raw html
  end

  # Returns a <select> list of forums, complete with display order, parenting and depth information
  # for when you need to select parent forums via the "Add New Forum" feature.
  #
  # @parm Array   An Array of all the forums present in the database
  # @parm Fixnum  The forum id that should be marked as selected
  # @parm Array   Any addtional options you would like to include in the <select> list
  def build_forum_chooser_options(forums, selected = nil, options = [])
    for forum in forums
      if forum.is_root? && !forum.can_contain_topics.nil?
        options.push(["#{forum.title}", forum.id])
        build_child_chooser_options(forum.descendants.arrange(:order => :display_order), options)
      end
    end

    options_for_select(options, :selected => selected)
  end

  # Recursive function to build a parent forum's children for <select> elements.
  #
  # @parm Hash    The nested hash of child forums
  # @parm Array   Array of select options previously built
  def build_child_chooser_options(forums, options)
    forums.each do |key, val|
      options.push(["#{depth_char(key.depth)} #{key.title}", key.id])
      if !val.empty?
        build_child_chooser_options(val, options)
      end
    end
    
    return options
  end
  
  # Returns an image_tag with the topic's proper status icon, which depends on a number of conditions,
  # like was the topic moved, is it closed, did the current user post in it, etc. All factors that 
  # chage the status icon shown.
  #
  # @parm Topic   The topic object we're checking against
  def build_status_icon topic
    file = ""
    
    # show that user replied?
    if logged_in?
      topic.posts.each do |post|
        if post.user_id == current_user.id
          file = "_dot"
        end
      end
    end
    
    # show hot folder?
    if topic.replies >= 15 || topic.views >= 150
      file << "_hot"
    end
    
    # is the topic locked?
    if !topic.open?
      file << "_lock"
    end
    
    # todo: add '_new' icon if the user hasn't viewed or read the thread. Requires the forum read 
    # feature to be implemented first.
    
    # check if topic is a redirect
    if topic.redirect?
      file = "_moved"
    end
    
    image_tag "/assets/forum/icons/thread#{file}.gif"
  end
end
