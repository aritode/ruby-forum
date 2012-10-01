module ForumsHelper
  # Builds an array of forum data based on the ids and collection info passed
  #
  # @param Array   The array of forum ids to build
  # @param Array   An Array of all the forums present in the database (avoids querying the db)
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
  # @param Hash    The nested hash of child forums
  # @param String  The HTML that will be rendered when finished
  def render_child_forums(forum, html = "")
    forum.each do |key, val|
      break if key.depth >= 2 # break iteration after max_depth is reach
      html << render(:partial => "level#{key.depth}_post", :locals => {:child => key})
      unless val.empty?
        render_child_forums(val, html)
      end
    end

    raw html
  end
  
  # Returns true if you're at the forums home page. I use this for constructing breadcrumbs mostly,
  # but could be useful for layouts & structuring pages, ads, etc.
  #
  # @return Boolean   Returns true if a visitor is at the forums home page.
  def is_forum_home?
    params[:controller] == 'forums' && params[:action] == 'index'
  end
  
  # Constructs a link with a list of sorting paramters for the topics list
  #
  # @param String   The linked text
  # @param String   The name of the sort field to sort by (e.g. lastpost, views, etc)
  def build_sort_link(text, sort)
    link_to(text, :sort => sort, 
      :order      => params[:order]     == 'desc' ? 'asc' : 'desc', 
      :page       => params[:page]      ||= 1, 
      :daysprune  => params[:daysprune] ||= -1
    )
  end
  
  # Repeats a character n amount of times to give forums their proper depth position in the tree.
  #
  # @param Integer The number of times to repeat the character
  # @param String  The actual character to use
  def depth_char(depth, depth_char = "--")
    char = ""
    depth.times do |d|
      char << depth_char
    end
    char
  end

  # Recursive function to render all child forums for a parent forum in the forums manager index.
  #
  # @param Hash    The nested hash of child forums
  # @param String  The HTML that will be rendered when finished
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
  # @param Array   An Array of all the forums present in the database
  # @param Fixnum  The forum id that should be marked as selected
  # @param Array   Any addtional options you would like to include in the <select> list
  def build_forum_chooser_options(forums, selected = nil, options = [])
    for forum in forums
      if forum.is_root? && !forum.is_forum.nil?
        options.push(["#{forum.title}", forum.id])
        build_child_chooser_options(forum.descendants.arrange(:order => :display_order), options)
      end
    end

    options_for_select(options, :selected => selected)
  end

  # Recursive function to build a parent forum's children for <select> elements.
  #
  # @param Hash    The nested hash of child forums
  # @param Array   Array of select options previously built
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
  # like was the topic moved, is it closed, did the current user post in it, etc. All factors that will
  # change the status icon that's shown.
  #
  # @param Topic   The topic object we're checking against
  def build_status_icon topic
    file = ""
    
    # show that user replied?
    if topic.posted
      file = "_dot"
    end
    
    # show hot folder?
    if topic.replies >= 15 or topic.views >= 150
      file << "_hot"
    end
    
    # is the topic locked?
    if !topic.open?
      file << "_lock"
    end

    # check if topic is a redirect
    if topic.redirect?
      file = "_moved"
    end

    # check for unread post
    if topic.unread_posts > 0
      file << "_new"
    end
    
    image_tag "/assets/forum/icons/thread#{file}.gif"
  end

  # Returns the new/old forum icon depending on if there are unread post or not.
  #
  # @param Forum  The forum object
  # @param Array  An array of forum ids that have unread post
  def fetch_forum_lightbulb forum, lightbulbs
    if lightbulbs.include?(forum.id)
       return image_tag "/assets/forum/icons/forum_new.gif"
    else
      if forum.child_list
        forum.child_list.split(',').each do |child_id|
          if lightbulbs.include?(child_id.to_i)
            return image_tag "/assets/forum/icons/forum_new.gif"
          else
            return image_tag "/assets/forum/icons/forum_old.gif"
          end
        end
      end
    end
    return image_tag "/assets/forum/icons/forum_old.gif"
  end

  # Returns the 'last_post' partial for said forum, taking child forums, etc. into account.
  #
  # @param Forum  The forum object
  # @param Hash   A hash of key->value results of all the forums last post info
  def fetch_forum_lastpost forum, lastposts
    if lastposts[forum.id]
      return render(:partial => "last_post", :locals => {:post => lastposts[forum.id]})
    else
      if forum.child_list
        forum.child_list.split(',').each do |child_id|
          if lastposts[child_id.to_i]
            return render(:partial => "last_post", :locals => {:post => lastposts[child_id.to_i]})
          end
        end
      end
    end
    "--"
  end
end