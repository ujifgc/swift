Admin.controllers :images do
  set_access :admin, :designer, :auditor, :editor

  before :edit, :update, :destroy do
    get_current_object
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
    @object = Image.new(params[:image])
    folder = Folder.get(session[:images_folder_id]) if session[:images_folder_id]
    @object.folder_id = folder && folder.id || Folder.last.id
    render 'images/new'
  end

  post :create do
    files = params[:image].delete 'file'
    title = params[:image].delete 'title'
    session[:images_folder_id] = params[:image][:folder_id]
    folder_id = params[:image].delete 'folder_id'
    if files.kind_of? Array
      num = files.count > 1 ? 1 : nil
      files.each do |file|
        filename = file[:filename]
        filename = File.basename filename, File.extname(filename)
        object = {
          :title => File.basename(title.blank? ? filename : "#{title} #{num}".strip, '.*').gsub('_', ' '),
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
      @object = Image.new params[:image].merge(:title => title, :folder_id => folder_id)
      @object.errors[:file] = [pat('error.select_file')]
      render 'images/new'
    end
  end

  before(:edit) { load_protocol_attributes }

  get :edit, :with => :id do
    render 'images/edit'
  end

  put :update, :with => :id do
    if @object.update(params[:image])
      flash[:notice] = pat('image.updated')
      redirect url_after_save
    else
      render 'images/edit'
    end
  end

  delete :destroy, :with => :id do
    if @object.destroy
      flash[:notice] = pat('image.destroyed')
    else
      flash[:error] = pat('image.not_destroyed')
    end
    redirect url(:images, :index)
  end
end
