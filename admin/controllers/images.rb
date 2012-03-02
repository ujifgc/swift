Admin.controllers :images do

  get :index do
    @objects = Image.all
    render 'images/index'
  end

  get :new do
    @object = Image.new
    render 'images/new'
  end

  post :create do
    files = params[:image].delete 'file'
    num = files.count > 1 ? 1 : nil
    files.each do |file|
      filename = file[:filename]
      filename = File.basename filename, File.extname(filename)
      object = {
        :title => (params[:image]['title'].blank? ? filename : "#{params[:image]['title']} #{num}".strip),
        :file => file
      }
      folder = Folder.get(params[:image]['folder_id'])
      object.merge! :folder => folder  if folder
      if Image.create object
        num += 1  if num
      end
    end
    flash[:notice] = pat('image.created')
    redirect url(:images, :index)
  end

  get :edit, :with => :id do
    @object = Image.get(params[:id])
    render 'images/edit'
  end

  put :update, :with => :id do
    @object = Image.get(params[:id])
    oldname = Padrino.public + @object.file.url
    if @object.update(params[:image])
      @obj = Image.get(params[:id])
      FileUtils.mv_try oldname, Padrino.public + @obj.file.url
      flash[:notice] = pat('image.updated')
      redirect url(:images, :edit, :id => @object.id)
    else
      render 'images/edit'
    end
  end

  delete :destroy, :with => :id do
    @object = Image.get(params[:id])
    if @object.destroy
      flash[:notice] = pat('image.destroyed')
    else
      flash[:error] = pat('image.not_destroyed')
    end
    redirect url(:images, :index)
  end
end
