Admin.controllers :dialogs do

  get :pages do
    @tree = page_tree( nil, 0, '' )
    render "dialogs/pages", :layout => :ajax
  end

  get :images do
    @objects = Image.all
    render "dialogs/images", :layout => :ajax
  end

  get :assets do
    render "dialogs/assets", :layout => :ajax
  end

  get :folder, :with => [:object_type, :folder_id] do
    folder = Folder.get params[:folder_id]
    case params[:object_type]
    when 'images'
      @objects = folder ? folder.images : Image.all
      render "dialogs/folder_images", :layout => :ajax
    when 'assets'
      @objects = folder ? folder.assets : Asset.all
      render "dialogs/folder_assets", :layout => :ajax
    else
      'error'
    end
  end

end
