Admin.controllers :layouts do

  get :index do
    @objects = Layout.all
    render 'layouts/index'
  end

  get :new do
    @object = Layout.new
    render 'layouts/new'
  end

  post :create do
    @object = Layout.new(params[:layout])
    if @object.save
      flash[:notice] = pat('layout.created')
      redirect url(:layouts, :edit, :slug => @object.slug)
    else
      render 'layouts/new'
    end
  end

  get :edit, :with => :slug do
    @object = Layout.get(params[:slug])
    render 'layouts/edit'
  end

  put :update, :with => :slug do
    @object = Layout.get(params[:slug])
    if @object.update(params[:layout])
      flash[:notice] = pat('layout.updated')
      redirect url(:layouts, :edit, :slug => @object.slug)
    else
      render 'layouts/edit'
    end
  end

  delete :destroy, :with => :slug do
    @object = Layout.get(params[:slug])
    if @object.destroy
      flash[:notice] = pat('layout.destroyed')
    else
      flash[:error] = pat('layout.not_destroyed')
    end
    redirect url(:layouts, :index)
  end
end
