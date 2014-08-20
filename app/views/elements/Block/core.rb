block = Block.by_slug @args[0]
throw :output, "[Block ##{@args[0]} missing]"  unless block
@text =
  case
  when Block::Types[block.type] == :html
    # this ensures that tagged HTML content is brought directly to response body without escaping
    block.text.html_safe
  when Block::Types[block.type] == :table && !@identity[:class].index('notitle')
    block.text.gsub!(/<table(.*?)>/m, "<table\\1>\n<caption>#{@opts[:title]||block.title}</caption>") unless @opts[:instance] == :notitle
    engine_render block.text
  else
    engine_render block.text
  end
