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
    filter[:folder_id] = params[:folder_id].to_i  if params[:folder_id]
    @objects = Asset.all filter
    render 'assets/index'
  end

  get :new do
    @object = Asset.new params
    render 'assets/new'
  end

  post :create do
    files = params[:asset].delete 'file'
    if files.kind_of? Array
      num = files.count > 1 ? 1 : nil
      files.each do |file|
        filename = file[:filename]
        filename = File.basename filename, File.extname(filename)
        object = {
          'title' => (params[:asset]['title'].blank? ? filename : "#{params[:asset]['title']} #{num}".strip),
          'file' => file,
        }
        folder = Folder.get(params[:asset]['folder_id'])
        object.merge! :folder => folder  if folder
        if Asset.create object
          num += 1  if num
        end
      end
      flash[:notice] = pat('asset.created')
      redirect url_after_save
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
      @object.remove_file
      if @object.update(params[:asset])
        @object.file = file
        @object.file.recreate_versions!
        @object.save
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
