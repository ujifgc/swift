if @opts[:folder]
  @folder = Folder.by_slug(@opts[:folder].to_a.sample) 
  @image = @folder.images.sample  if @folder
else
  @folder = (Bond.all.children_for @page, 'Folder').sample
  @image = @folder.images.sample  if @folder
end
