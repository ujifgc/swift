Admin.controllers :folders do

  get :index do
    @objects = Folder.all
    render 'folders/index'
  end

  get :new do
    @object = Folder.new
    render 'folders/new'
  end

  post :create do
    @object = Folder.new(params[:folder])
    if @object.save
      flash[:notice] = pat('folder.created')
      redirect url(:folders, :edit, :id => @object.id)
    else
      render 'folders/new'
    end
  end

  get :edit, :with => :id do
    @object = Folder.get(params[:id])
    render 'folders/edit'
  end

  put :update, :with => :id do
    @object = Folder.get(params[:id])
    if @folder.update(params[:folder])
      flash[:notice] = pat('folder.updated')
      redirect url(:folders, :edit, :id => @object.id)
    else
      render 'folders/edit'
    end
  end

  delete :destroy, :with => :id do
    @object = Folder.get(params[:id])
    if @object.destroy
      flash[:notice] = pat('folder.destroyed')
    else
      flash[:error] = pat('folder.not_destroyed')
    end
    redirect url(:folders, :index)
  end
end
