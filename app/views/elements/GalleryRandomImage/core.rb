@folder = if @opts[:folder]
  Folder.all( :slug => Array(@opts[:folder]||@opts[:folders]) ).sample
else
  Bond.children_for(@page, 'Folder').sample
end
throw :output, "[No bound folders for GalleryRandomImage]"  unless @folder
@image = @folder.images.sample
throw :output, "[No images in Folder##{@folder.slug}]"  unless @image
