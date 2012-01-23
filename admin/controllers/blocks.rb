Admin.controllers :blocks do

  get :index do
    @blocks = Block.all
    render 'blocks/index'
  end

  get :new do
    @block = Block.new
    render 'blocks/new'
  end

  post :create do
    @block = Block.new(params[:block])
    if @block.save
      flash[:notice] = 'Block was successfully created.'
      redirect url(:blocks, :edit, :id => @block.id)
    else
      render 'blocks/new'
    end
  end

  get :edit, :with => :id do
    @block = Block.get(params[:id])
    render 'blocks/edit'
  end

  put :update, :with => :id do
    @block = Block.get(params[:id])
    if @block.update(params[:block])
      flash[:notice] = 'Block was successfully updated.'
      redirect url(:blocks, :edit, :id => @block.id)
    else
      render 'blocks/edit'
    end
  end

  delete :destroy, :with => :id do
    block = Block.get(params[:id])
    if block.destroy
      flash[:notice] = 'Block was successfully destroyed.'
    else
      flash[:error] = 'Unable to destroy Block!'
    end
    redirect url(:blocks, :index)
  end
end
