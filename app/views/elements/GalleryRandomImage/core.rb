@folder = if @opts[:folder]
  case @opts[:folder]
  when Symbol, String
    Folder.all( :slug => Array(@opts[:folder]) ).sample
  else
    @opts[:folder].sample
  end
else
  Bond.children_for(@page, 'Folder').sample
end
throw :output, "[No bound folders for GalleryRandomImage]"  unless @folder
@image = @folder.images.sample
throw :output, "[No images in Folder##{@folder.slug}]"  unless @image
