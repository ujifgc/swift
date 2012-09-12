@image = Image.get @args[0]
return "[Image ##{@args[0]} missing]"  unless @image
