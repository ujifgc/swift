Admin.controllers :codes do
  set_access :admin, :designer

  before :edit, :update, :destroy do
    @object = Code.get(params[:id])
    unless @object
      flash[:error] = pat('object.not_found')
      redirect url(:codes, :index)
    end
  end

  get :index do
    @objects = Code.all
    render 'codes/index'
  end

  get :new do
    @object = Code.new
    render 'codes/new'
  end

  post :create do
    @object = Code.new(params[:code])
    if @object.save
      flash[:notice] = pat('code.created')
      redirect url_after_save
    else
      render 'codes/new'
    end
  end

  get :edit, :with => :id do
    @object = Code.get(params[:id])
    render 'codes/edit'
  end

  put :update, :with => :id do
    @object = Code.get(params[:id])
    if @object.update(params[:code])
      flash[:notice] = pat('code.updated')
      redirect url_after_save
    else
      render 'codes/edit'
    end
  end

  delete :destroy, :with => :id do
    @object = Code.get(params[:id])
    if @object.destroy
      flash[:notice] = pat('code.destroyed')
    else
      flash[:error] = pat('code.not_destroyed')
    end
    redirect url(:codes, :index)
  end
end
