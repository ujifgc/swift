@galleries = []
folders = Bond.all.children_for @page, 'Folder'
folders.each do |f|
  if f.images.count > 0
    @galleries << f
  end  
end
