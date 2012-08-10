module Admincp::ForumsHelper
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
        render_child_forums(val, html)
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
  def construct_forum_chooser_options(forums, selected = nil, options = [])
    for forum in forums
      if forum.is_root? && !forum.can_contain_topics.nil?
        options.push(["#{forum.name}", forum.id])
        construct_child_chooser_options(forum.descendants.arrange(:order => :display_order), options)
      end
    end

    options_for_select(options, :selected => selected)
  end

  # Recursive function to build a parent forum's children for <select> elements.
  #
  # @parm Hash    The nested hash of child forums
  # @parm Array   Array of select options previously built
  def construct_child_chooser_options(forums, options)
    forums.each do |key, val|
      options.push(["#{depth_char(key.depth)} #{key.name}", key.id])
      if !val.empty?
        construct_child_chooser_options(val, options)
      end
    end
    
    return options
  end
end
