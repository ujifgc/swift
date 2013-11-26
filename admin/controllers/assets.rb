Admin.controllers :assets do
    
  before :edit, :update, :destroy do
    @object = Asset.get(params[:id].to_i)
    unless @object
      flash[:error] = pat('object.not_found')
      redirect url(:assets, :index)
    end
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
      @object = Asset.new params[:asset]
      @object.errors[:file] = [pat('error.select_file')]
      render 'assets/new'
    end
  end

  get :edit, :with => :id do
    @object = Asset.get(params[:id])
    render 'assets/edit'
  end

  put :update, :with => :id do
    @object = Asset.get(params[:id])
    file = params[:asset].delete 'file'
    if file.kind_of? Hash
      if @object.update(params[:asset])
        @object.file = file
        @object.save
        @object.file.cleanup!
        flash[:notice] = pat('asset.updated')
        redirect url_after_save
      else
        render 'assets/edit'
      end
    else
      oldname = Padrino.public + @object.file.url
      if @object.update(params[:asset])
        @obj = Asset.get(params[:id])
        FileUtils.mv_try oldname, Padrino.public + @obj.file.url
        flash[:notice] = pat('asset.updated')
        redirect url_after_save
      else
        render 'assets/edit'
      end
    end
  end

  delete :destroy, :with => :id do
    @object = Asset.get(params[:id])
    if @object.destroy
      flash[:notice] = pat('asset.destroyed')
    else
      flash[:error] = pat('asset.not_destroyed')
    end
    redirect url(:assets, :index)
  end
end
