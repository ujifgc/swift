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
    filename = params[:asset]['file'][:filename]
    filename = File.basename filename, File.extname(filename)
    params[:asset]['title'] = filename  if params[:asset]['title'].blank?
    @object = Asset.new(params[:asset])
    if @object.save
      flash[:notice] = pat('asset.created')
      redirect url(:assets, :edit, :id => @object.id)
    else
      render 'assets/new'
    end
  end

  get :edit, :with => :id do
    @object = Asset.get(params[:id])
    render 'assets/edit'
  end

  put :update, :with => :id do
    @object = Asset.get(params[:id])
    if @object.update(params[:asset])
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
