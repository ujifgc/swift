Admin.controllers :folders do

  before :edit, :update, :destroy do
    @object = Folder.get(params[:id])
    unless @object
      flash[:error] = pat('object.not_found')
      redirect url(:folders, :index)
    end
  end

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
    old_slug = @object.slug
    old_img_dir = Image.new( :folder => @object ).file.store_dir
    old_doc_dir = Asset.new( :folder => @object ).file.store_dir
    if @object.update(params[:folder])
      unless old_slug == @object.slug
        new_img_dir = Image.new( :folder => @object ).file.store_dir
        new_doc_dir = Asset.new( :folder => @object ).file.store_dir
        File.rename( Padrino.public / old_img_dir, Padrino.public / new_img_dir )  rescue nil
        File.rename( Padrino.public / old_doc_dir, Padrino.public / new_doc_dir )  rescue nil
      end
      flash[:notice] = pat('folder.updated')
      redirect url_after_save
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
