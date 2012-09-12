@block = Block.by_slug @args[0]
return "[Block ##{@args[0]} missing]"  unless @block
