module Admincp::ForumsHelper
  # Repeats a character x amount of times to give forums their proper depth in a tree.
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

  # Recursive function to render all child forums for a parent forum.
  #
  # @parm Hash    The nested hash of child forums
  # @parm String  The HTML that will be rendered when finished
  def render_child_forums(hash, html = "")
    hash.each do |key, val|
      html << render(:partial => 'forum', :locals => {:forum => key})
      if !val.empty?
        render_descendants(val, html)
      end
    end

    return raw html
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
end
