module ForumsHelper
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
