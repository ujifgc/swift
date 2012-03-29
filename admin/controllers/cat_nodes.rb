Admin.controllers :cat_nodes do

  get :index do
    @objects = CatNode.all
    render 'cat_nodes/index'
  end

  get :new do
    @object = CatNode.new
    render 'cat_nodes/new'
  end

  post :create do
    @object = CatNode.new(params[:cat_node])
    if @object.save
      flash[:notice] = pat('cat_node.created')
      redirect url(:cat_nodes, :edit, :id => @object.id)
    else
      render 'cat_nodes/new'
    end
  end

  get :edit, :with => :id do
    @object = CatNode.get(params[:id])
    render 'cat_nodes/edit'
  end

  put :update, :with => :id do
    @object = CatNode.get(params[:id])
    if @object.update(params[:cat_node])
      flash[:notice] = pat('cat_node.updated')
      redirect url(:cat_nodes, :index)
    else
      render 'cat_nodes/edit'
    end
  end

  delete :destroy, :with => :id do
    @object = CatNode.get(params[:id])
    if @object.destroy
      flash[:notice] = pat('cat_node.destroyed')
    else
      flash[:error] = pat('cat_node.not_destroyed')
    end
    redirect url(:cat_nodes, :index)
  end
end
