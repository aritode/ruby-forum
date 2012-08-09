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
end
