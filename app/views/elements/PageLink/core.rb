@link = Pages.with_pk(@args[0])
throw :output, "[Page ##{@args[0]} missing]"  unless @link
