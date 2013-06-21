if swift.slug != ''
  @folder = Folder.by_slug(swift.slug)
  not_found  unless @folder
  swift.path_pages << Page.new
  @opts[:folder] = swift.slug
  throw :output, element( 'GalleryFolder', *@args, @opts )
else 
  throw :output, element( 'GalleryList', *@args, @opts )
end
