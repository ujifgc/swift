Admin.controllers :elements do
  set_access :admin, :designer

  before :edit, :update, :destroy do
    @object = Element.get(params[:id])
    unless @object
      flash[:error] = pat('object.not_found')
      redirect url(:elements, :index)
    end
  end

  get :index do
    @objects = Element.all
    render 'elements/index'
  end

  get :new do
    @object = Element.new
    render 'elements/new'
  end

  post :create do
    @object = Element.new(params[:element])
    if @object.save
      flash[:notice] = pat('element.created')
      redirect url_after_save
    else
      render 'elements/new'
    end
  end

  before(:edit) { load_protocol_attributes }

  get :edit, :with => :id do
    render 'elements/edit'
  end

  put :update, :with => :id do
    if @object.update(params[:element])
      flash[:notice] = pat('element.updated')
      redirect url_after_save
    else
      render 'elements/edit'
    end
  end

  delete :destroy, :with => :id do
    if @object.destroy
      flash[:notice] = pat('element.destroyed')
    else
      flash[:error] = pat('element.not_destroyed')
    end
    redirect url(:elements, :index)
  end
end
