module ApplicationHelper

  @@bbcode2text_parser = RbbCode::Parser.new
  
  def bbcode2text(string, length=nil)
    s = strip_tags(string)
    # work around to avoid a bug of RbbCode, that raises an error when 2 tags have no text in beetween
    s.gsub!('][', '] [')
    # other work around to avoid another bug when it encounter \r\n as LIST separator
    s.gsub!(/\r/, "\n")
    # other work around to avoid another bug when it encounter a blank LIST
    s.gsub!(/\[LIST\][\s]*\[\/LIST\]/i, '')
    s = @@bbcode2text_parser.parse(s)
    length ? s.truncate(length) : s
  end
end
