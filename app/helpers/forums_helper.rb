module ForumsHelper

  def construct_forum_manager(forum, forums, html = "", depth = 1, depth_char = "- - ")
    
    char = construct_depth_char(depth, depth_char)
    
    if forum.has_children?
      for child in build_child_info(forum.child_ids, forums)
        html << %Q{
          <tr class="odd gradeX">
            <td width="50%">
              <strong>#{char} #{link_to child.name, admincp_edit_forum_path(child)}</a></strong>
            </td>
            <td><input type="text" name="order[#{child.id}]" value="#{child.display_order}" tabindex="1" size="3" title="Edit Display Order"/></td>
            <td>
              <select name="f#{child.id}" onchange="js_forum_jump(#{child.id});">
                <option value="edit">Edit Forum</option>
                <option value="view">View Forum</option>
                <option value="remove">Delete Forum</option>
                <option value="add">Add Child Forum</option>
              </select>
              <input type="button" class="btn btn-small btn-quaternary" value="Go" onclick="js_forum_jump(#{child.id});"/>
            </td>
          </tr>
        }

        construct_forum_manager(child, forums, html, depth + 1)
      end
      
      return html
    end
  end

  def construct_depth_char(depth, depth_char = "--")
    char = ""
    depth.times do |d|
      char << depth_char
    end
    return char
  end

  # Returns a <select> list of forums, complete with display order, parenting and depth information
  # for when you need to select parent forums via the "Add New Forum" feature.
  #
  # @parm Array   An Array of all the forums present in the database
  # @parm Fixnum  The forum id that should be marked as selected
  def construct_forum_chooser_options(collection, selected = nil)
    options = []
    for forum in collection
      if forum.is_root? && !forum.can_contain_topics.nil?
        options.push(["-- #{forum.name}", forum.id])
        construct_child_forums(forum, options, collection)
      end
    end

    options_for_select(options, :selected => selected)
  end

  # Recursive function to build a parent forum's children for <select> elements.
  #
  # @parm Forum   The root forum object we're checking for children
  # @parm Array   Previously built array of forums
  # @parm Array   An Array of all the forums present in the database (avoids querying the db)
  # @parm Fixnum  The depth level we're currently at
  # @parm String  The charector to use to determine the depth of a forum
  def construct_child_forums(forum, options, collection, depth = 1, depth_char = "--")
    if forum.has_children?
      char = ""
      depth.times do |d|
        char << depth_char
      end

      for child in build_child_info(forum.child_ids, collection)
        options.push(["--#{char} #{child.name}", child.id])
        construct_child_forums(child, options, collection, depth + 1)
      end
    end
  end
  
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

end
