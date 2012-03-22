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
    @objects = Asset.all
    render "dialogs/assets", :layout => :ajax
  end

  get :folders do
    @objects = Folder.all
    render "dialogs/folders", :layout => :ajax
  end

  get :folder, :with => [:object_type, :folder_id] do
    folder = Folder.by_slug params[:folder_id]
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

  get :bonds, :with => [:parent_model, :parent_id] do
    render "dialogs/bonds", :layout => :ajax
  end

  get :bond, :with => [:parent_model, :parent_id] do
    @model = params[:parent_model].constantize  rescue nil
    return "no such model: #{params[:parent_model]}"  unless @model
    @object = @model.get params[:parent_id]
    return "no such object: #{model} ##{params[:parent_id]}"  unless @object
    @bonds = Bond.children_for @object
    render "dialogs/bonds_tab", :layout => :ajax
  end

end
