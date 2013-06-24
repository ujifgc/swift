Admin.controllers :images do

  before :edit, :update, :destroy do
    @object = Image.get(params[:id])
    unless @object
      flash[:error] = pat('object.not_found')
      redirect url(:images, :index)
    end
  end

  get :index do
    filter = {}
    if params[:folder_id]
      filter[:folder_id] = params[:folder_id].to_i  unless params[:folder_id] == 'all'
    else
      folder = Folder.with(:images).last      
      filter[:folder_id] = params[:folder_id] = folder.id  if folder
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
    title = params[:image].delete 'title'
    folder_id = params[:image].delete 'folder_id'
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
        object.merge! params[:image]
        @object = Image.create object
        num += 1  if num
      end
      flash[:notice] = pat('image.created')
      redirect (files.count > 1) ? url(:images, :index) : url_after_save
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
      if @object.update(params[:image])
        @object.file = file
        @object.save
        @object.file.cleanup!
        flash[:notice] = pat('image.updated')
        redirect url_after_save
      else
        render 'images/edit'
      end
    else
      oldname = Padrino.public + @object.file.url
      if @object.update(params[:image])
        @obj = Image.get(params[:id])
        FileUtils.mv_try oldname, Padrino.public + @obj.file.url
        flash[:notice] = pat('image.updated')
        redirect url_after_save
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
