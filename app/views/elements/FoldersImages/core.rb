if @folder ||= Folder.by_slug( @args[0] || @opts[:folder] || @opts[:gallery] )
  @page = @folder
  @images = @folder.images
else
  @images = []
  bonds = Bond.bonds_for @page
  bonds.map do |bond|
    case bond.child_model
    when 'Image'
      @images << bond.child
    when 'Folder'
      @images += bond.child.images
    end
  end
end
