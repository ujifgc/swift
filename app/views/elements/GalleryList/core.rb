@galleries = []
folders = Folder.all
folders.each do |f|
  if f.images.count > 0
    @galleries << f
  end  
end
