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
    throw files
    filename = params[:image]['file'][:filename]
    filename = File.basename filename, File.extname(filename)
    params[:image]['title'] = filename  if params[:image]['title'].blank?
    @object = Image.new(params[:image])
    if @object.save
      flash[:notice] = pat('image.created')
      redirect url(:images, :edit, :id => @object.id)
    else
      render 'images/new'
    end
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
