Admin.controllers :dialogs do
  layout :ajax

  get :codes do
    @objects = Code.all :order => :title
    @title = pat 'dialog.pick_code'
    render "dialogs/pick_codes", :layout => params.has_key?('pick') ? 'pick_many' : 'ajax'
  end

  get :pages do
    @tree = page_tree( nil, 0, '', :published )
    @title = pat 'dialog.pick_page'
    render "dialogs/pick_pages", :layout => params.has_key?('pick') ? 'pick_many' : 'ajax'
  end

  get :blocks do
    @objects = Block.all :order => :title
    @title = pat 'dialog.pick_block'
    render "dialogs/pick_blocks", :layout => params.has_key?('pick') ? 'pick_many' : 'ajax'
  end

  get :images do
    @objects = Image.all :order => :updated_at.desc
    @title = pat 'dialog.pick_image'
    render "dialogs/pick_images", :layout => params.has_key?('pick') ? 'pick_many' : 'ajax'
  end

  get :assets do
    @objects = Asset.all :order => :updated_at.desc
    @title = pat 'dialog.pick_asset'
    render "dialogs/pick_assets", :layout => params.has_key?('pick') ? 'pick_many' : 'ajax'
  end

  get :create_parent do
    @title = pat 'dialog.create_' + params[:parent_model].downcase
    render "dialogs/create_parent", :layout => :dialog
  end

  post :create_parent do
    content_type 'text/html'
    @object = params[:parent_model].constantize.create :title => params[:parent_title]
    return "error creating title: #{params[:parent_title]}"  unless @object

    content_type 'application/json'
    render "dialogs/create_parent.json"
  end

  get :dropdown_codes do
    @objects = Code.all :is_system => false
    if params.has_key?('drop')
      render "dialogs/dropdown_codes"
    else
      render "dialogs/dialog_codes", :layout => :dialog
    end
  end

  get :folders do
    @objects = Folder.all
    render "dialogs/folders"
  end

  get :cat_groups do
    @objects = CatGroup.all
    render "dialogs/cat_groups"
  end

  get :cat_cards do
    @objects = CatCard.all
    render "dialogs/cat_cards"
  end

  get :cat_nodes do
    @objects = CatNode.all
    render "dialogs/cat_nodes"
  end

  get :news_rubrics do
    @objects = NewsRubric.all
    render "dialogs/news_rubrics"
  end

  get :forms_cards do
    @objects = FormsCard.all #:kind => 'inquiry'
    render "dialogs/forms_cards"
  end

  get :folder, :with => [:object_type, :folder_id] do
    folder = Folder.by_slug params[:folder_id]
    filter = { :order => :created_at.desc }
    case params[:object_type]
    when 'images'
      @objects = folder ? folder.images(filter) : Image.all(filter)
      render "dialogs/folder_images"
    when 'assets'
      @objects = folder ? folder.assets(filter) : Asset.all(filter)
      render "dialogs/folder_assets"
    else
      'error'
    end
  end

  post :preview, :with => [:model, :id] do
    @title = pat 'dialog.preview'
    @content = if params[:text]
      engine_render( params[:text] )
    else
      @model = params[:model].constantize  rescue nil
      return "no such model: #{params[:model]}"  unless @model
      @object = @model.get params[:id]
      return "no such object: #{model} ##{params[:id]}"  unless @object
      engine_render( @object.text )
    end
    render 'dialogs/preview', :layout => :dialog_slim
  end

  get :bonds, :with => [:parent_model, :parent_id] do
    @title = pat 'dialog.select_bonds'
    halt 405  unless request.xhr?
    render "dialogs/bonds", :layout => :dialog
  end

  get :bond, :with => [:parent_model, :parent_id] do
    @model = params[:parent_model].constantize  rescue nil
    return "no such model: #{params[:parent_model]}"  unless @model
    @object = @model.get params[:parent_id]
    return "no such object: #{model} ##{params[:parent_id]}"  unless @object
    @bonds = Bond.bonds_for @object
    render "dialogs/bonds_tab"
  end

  post :bonds_ajax, :with => [:parent_model, :parent_id] do
    content_type 'text/html'
    @model = params[:parent_model].constantize  rescue nil
    return "no such model: #{params[:parent_model]}"  unless @model
    @parent = @model.get params[:parent_id]
    return "no such parent: #{@model} ##{params[:parent_id]}"  unless @parent
    content_type 'application/json'

    Bond.separate @parent
    Array(params['bond']).each do |child_model, child_ids|
      @child_model = child_model.constantize  rescue nil
      return "no such model: #{@child_model}"  unless @child_model
      Array(child_ids).each do |child_id, value|
        next  unless value == 'on'
        @child = @child_model.get child_id
        return "no such child: #{@child_model} ##{child_id}"  unless @child
        return "failed to generate bond"  unless Bond.generate @parent, @child
      end      
    end
    
    @answer = { notice: 'all fine' }
    render "dialogs/bonds_ajax"
  end

end
