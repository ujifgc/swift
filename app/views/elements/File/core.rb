@file = Asset.first :id => @args[0]
throw :output, "[Asset ##{@args[0]} missing]"  unless @file
