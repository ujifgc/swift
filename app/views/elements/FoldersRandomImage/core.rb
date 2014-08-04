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

@image_src = begin
  @opts[:outlet] ? @image.file.outlets[@opts[:outlet].to_sym].url : @image.file.index_thumb.url
rescue NoMethodError
  @image.file.url
end

throw :output, image_tag(@image_src, :alt => @image.title) if @opts[:raw]
