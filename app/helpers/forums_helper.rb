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
  
end
