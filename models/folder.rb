class Folders < Sequel::Model
  def absolute_pathz
    if is_private
      Padrino.root('private', NeatAdapter::FILES_FOLDER, path)
    else
      Padrino.public(NeatAdapter::FILES_FOLDER, path)
    end
  end
end
