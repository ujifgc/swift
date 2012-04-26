Admin.controllers :images do

  get :index do
    filter = {}
    unless params[:folder].blank?
      filter[:folder] = Folder.by_slug params[:folder]
    end
    @objects = Image.all filter
    render 'images/index'
  end

  get :new do
    @object = Image.new params
    render 'images/new'
  end

  post :create do
    files = params[:image].delete 'file'
    if files.kind_of? Array
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
    else
      @object = Image.new params[:image]
      @object.errors[:file] = [pat('error.select_file')]
      render 'images/new'
    end
  end

  get :edit, :with => :id do
    @object = Image.get(params[:id])
    render 'images/edit'
  end

  put :update, :with => :id do
    @object = Image.get(params[:id])
    file = params[:image].delete 'file'
    if file.kind_of? Hash
      @object.remove_file
      if @object.update(params[:image])
        @object.file = file
        @object.file.recreate_versions!
        @object.save
        flash[:notice] = pat('image.updated')
        redirect url(:images, :index)
      else
        render 'images/edit'
      end
    else
      oldname = Padrino.public + @object.file.url
      if @object.update(params[:image])
        @obj = Image.get(params[:id])
        FileUtils.mv_try oldname, Padrino.public + @obj.file.url
        flash[:notice] = pat('image.updated')
        redirect url(:images, :index)
      else
        render 'images/edit'
      end
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
