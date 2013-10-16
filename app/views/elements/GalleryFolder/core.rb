if folder = Folder.by_slug( @args[0] || @opts[:folder] || @opts[:gallery] )
  @pics = Image.all :folder => folder
else
  @pics = []
  bonds = Bond.bonds_for @page
  bonds.map do |bond|
    case bond.child_model
    when 'Image'
      @pics << bond.child
    when 'Folder'
      @pics += bond.child.images
    end
  end
end
