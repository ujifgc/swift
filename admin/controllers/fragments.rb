Admin.controllers :fragments do

  get :index do
    @basics = Fragment.all :is_fragment => false
    @fragments = Fragment.fragments
    render 'fragments/index'
  end

  get :new do
    @object = Fragment.new
    render 'fragments/new'
  end

  post :create do
    @object = Fragment.new(params[:fragment])
    if @object.save
      flash[:notice] = pat('fragment.created')
      redirect url(:fragments, :edit, :slug => @object.slug)
    else
      render 'fragments/new'
    end
  end

  get :edit, :with => :slug do
    @object = Fragment.get(params[:slug])
    render 'fragments/edit'
  end

  put :update, :with => :slug do
    @object = Fragment.get(params[:slug])
    if @object.update(params[:fragment])
      flash[:notice] = pat('fragment.updated')
      redirect url(:fragments, :edit, :slug => @object.slug)
    else
      render 'fragments/edit'
    end
  end

  delete :destroy, :with => :slug do
    @object = Fragment.get(params[:slug])
    if @object.destroy
      flash[:notice] = pat('fragment.destroyed')
    else
      flash[:error] = pat('fragment.not_destroyed')
    end
    redirect url(:fragments, :index)
  end
end
