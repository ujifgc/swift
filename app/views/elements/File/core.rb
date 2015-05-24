@file = Assets.with_pk(@args[0])
throw :output, "[Asset ##{@args[0]} missing]"  unless @file
