Admin.controllers :folders do
  set_access :admin, :designer, :auditor, :editor

  before :edit, :update, :destroy do
    @object = Folder.get(params[:id])
    unless @object
      flash[:error] = pat('flash.folder_not_found')
      redirect url(:folders, :index)
    end
  end

  get :index do
    @objects = Folder.all(:order => :slug)
    render 'folders/index'
  end

  get :new do
    @object = Folder.new
    render 'folders/new'
  end

  post :create do
    @object = Folder.new(params[:folder])
    if @object.save
      flash[:notice] = pat('flash.folder_created')
      redirect url_after_save
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
    old_path = @object.path
    old_dir = @object.absolute_path
    fail RuntimeError  unless File.exist?(old_dir)
    if @object.update(params[:folder])
      unless old_dir == @object.absolute_path
        FileUtils.mkdir_p(@object.absolute_path)
        File.rename(old_dir, @object.absolute_path)
      end
      flash[:notice] = pat('flash.folder_updated')
      redirect url_after_save
    else
      render 'folders/edit'
    end
  end

  delete :destroy, :with => :id do
    @object = Folder.get(params[:id])
    if @object.destroy
      flash[:notice] = pat('flash.folder_destroyed')
    else
      flash[:error] = pat('flash.folder_not_destroyed')
    end
    redirect url(:folders, :index)
  end
end
