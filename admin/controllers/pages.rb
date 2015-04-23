Admin.controllers :pages do
  set_access :admin, :designer, :auditor, :editor

  before :edit, :update, :destroy do
    get_current_object
    if params[:page] && current_account.allowed?(:auditor) && !current_account.allowed?(:admin)
      params[:page]['is_module'] = @object.fragment.is_module
    end
  end

  get :index do
    @tree = page_tree( nil, 0, '' )
    render 'pages/index'
  end

  get :new do
    @object = Page.new
    render 'pages/new'
  end

  post :create do
    @object = Page.new(params[:page])
    if @object.save
      flash[:notice] = pat('page.created')
      redirect url_after_save
    else
      render 'pages/new'
    end
  end

  before(:edit) { load_protocol_attributes }

  get :edit, :with => :id do
    render 'pages/edit'
  end

  put :update, :with => :id do
    if @object.update(params[:page])
      flash[:notice] = pat('page.updated')
      redirect url_after_save
    else
      render 'pages/edit'
    end
  end

  post :reposition, :with => [:id, :direction] do
    @object = Page.get(params[:id])
    @object.reposition! params[:direction]  if @object
    @tree = page_tree( nil, 0, '' )
    render 'pages/index', :layout => false
  end

  delete :destroy, :with => :id do
    if @object.destroy
      flash[:notice] = pat('page.destroyed')
    else
      flash[:error] = pat('page.not_destroyed')
    end
    redirect url(:pages, :index)
  end
end
