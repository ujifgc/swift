block = Block.by_slug(@args[0] || 'sliders')
throw :output, "[Block ##{@args[0]} missing]"  unless block
@sliders = block.text.split(/---+/).map(&:strip).reject(&:blank?).map(&method(:split_image))
