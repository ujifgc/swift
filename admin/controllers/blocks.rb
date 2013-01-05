Admin.controllers :blocks do

  before :edit, :update, :destroy do
    @object = Block.get(params[:id])
    unless @object
      flash[:error] = pat('object.not_found')
      redirect url(:blocks, :index)
    end
  end

  get :index do
    @objects = Block.all
    render 'blocks/index'
  end

  get :new do
    @object = Block.new
    render 'blocks/new'
  end

  post :create do
    @object = Block.new(params[:block])
    if @object.save
      flash[:notice] = pat('block.created')
      redirect url_after_save
    else
      render 'blocks/new'
    end
  end

  get :edit, :with => :id do
    @object = Block.get(params[:id])
    render 'blocks/edit'
  end

  put :update, :with => :id do
    @object = Block.get(params[:id])
    if @object.update(params[:block])
      flash[:notice] = pat('block.updated')
      redirect url_after_save
    else
      render 'blocks/edit'
    end
  end

  delete :destroy, :with => :id do
    @object = Block.get(params[:id])
    if @object.destroy
      flash[:notice] = pat('block.destroyed')
    else
      flash[:error] = pat('block.not_destroyed')
    end
    redirect url(:blocks, :index)
  end
end
