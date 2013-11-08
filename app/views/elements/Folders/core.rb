if swift.slug == ''
  throw :output, element( 'FoldersList', *@args, @opts )
else 
  @folder = Folder.by_slug(swift.slug)
  not_found  unless @folder
  swift.path_pages << Page.new( :title => @folder.title )
  throw :output, element( 'FoldersImages', *@args, @opts )
end
