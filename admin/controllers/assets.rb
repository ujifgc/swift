Admin.controllers :assets do
  set_access :admin, :designer, :auditor, :editor
    
  before :edit, :update, :destroy do
    get_current_object
  end

  get :index do
    filter = {}
    if params[:folder_id]
      filter[:folder_id] = params[:folder_id].to_i  unless params[:folder_id] == 'all'
    else
      folder = Folder.with(:assets).last
      filter[:folder_id] = params[:folder_id] = folder.id  if folder
    end
    @objects = Asset.all filter
    render 'assets/index'
  end

  get :new do
    @object = Asset.new params
    render 'assets/new'
  end

  post :create do
    files = params[:asset].delete 'file'
    title = params[:asset].delete 'title'
    folder_id = params[:asset].delete 'folder_id'
    if files.kind_of? Array
      num = files.count > 1 ? 1 : nil
      files.each do |file|
        filename = file[:filename]
        filename = File.basename filename, File.extname(filename)
        object = {
          :title => (title.blank? ? filename : "#{title} #{num}".strip),
          :file => file
        }
        folder = Folder.get folder_id
        object.merge! :folder => folder  if folder
        object.merge! params[:asset]
        @object = Asset.create object
        num += 1  if num
      end
      flash[:notice] = pat('asset.created')
      redirect (files.count > 1) ? url(:assets, :index) : url_after_save
    else
      @object = Asset.new params[:asset].merge(:title => title, :folder_id => folder_id)
      @object.errors[:file] = [pat('error.select_file')]
      render 'assets/new'
    end
  end

  before(:edit) { load_protocol_attributes }

  get :edit, :with => :id do
    render 'assets/edit'
  end

  put :update, :with => :id do
    if @object.update(params[:asset])
      flash[:notice] = pat('asset.updated')
      redirect url_after_save
    else
      render 'assets/edit'
    end
  end

  delete :destroy, :with => :id do
    if @object.destroy
      flash[:notice] = pat('asset.destroyed')
    else
      flash[:error] = pat('asset.not_destroyed')
    end
    redirect url(:assets, :index)
  end
end
