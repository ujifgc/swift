Admin.controllers :cat_cards do
  before :edit, :update, :destroy do
    @object = CatCard.get(params[:id])
    unless @object
      flash[:error] = pat('object.not_found')
      redirect url(:cat_cards, :index)
    end
  end
  
  get :index do
    @objects = CatCard.all
    render 'cat_cards/index'
  end

  get :new do
    @object = CatCard.new
    render 'cat_cards/new'
  end

  post :create do
    @object = CatCard.new(params[:cat_card])
    @object.fill_json params, :cat_nodes
    if @object.save
      flash[:notice] = pat('cat_card.created')
      redirect url_after_save
    else
      render 'cat_cards/new'
    end
  end

  get :edit, :with => :id do
    @object = CatCard.get(params[:id])
    render 'cat_cards/edit'
  end

  put :update, :with => :id do
    @object = CatCard.get(params[:id])
    @object.attributes = params[:cat_card]
    @object.fill_json params, :cat_nodes
    if @object.save
      flash[:notice] = pat('cat_card.updated')
      redirect url_after_save
    else
      render 'cat_cards/edit'
    end
  end

  delete :destroy, :with => :id do
    @object = CatCard.get(params[:id])
    if @object.destroy
      flash[:notice] = pat('cat_card.destroyed')
    else
      flash[:error] = pat('cat_card.not_destroyed')
    end
    redirect url(:cat_cards, :index)
  end
end
