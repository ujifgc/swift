Admin.controllers :assets do

  get :index do
    @objects = Asset.all
    render 'assets/index'
  end

  get :new do
    @object = Asset.new
    render 'assets/new'
  end

  post :create do
    files = params[:asset].delete 'file'
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
    redirect url(:assets, :index)
  end

  get :edit, :with => :id do
    @object = Asset.get(params[:id])
    render 'assets/edit'
  end

  put :update, :with => :id do
    @object = Asset.get(params[:id])
    oldname = Padrino.public + @object.file.url
    if @object.update(params[:asset])
      @obj = Asset.get(params[:id])
      FileUtils.mv_try oldname, Padrino.public + @obj.file.url
      flash[:notice] = pat('asset.updated')
      redirect url(:assets, :edit, :id => @object.id)
    else
      render 'assets/edit'
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
