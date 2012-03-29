#
Admin.controllers :cat_cards do
  before :create, :update do
    keys = params.delete 'key'
    types = params.delete 'type'
    all = Hash[keys.zip types].reject{|k,v|k.blank?}
    fields = all.reject{|k,v|v.blank?}
    @deletes = all.select{|k,v|v.blank?}
    params[:cat_card].merge! fields
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
    if @object.save
      flash[:notice] = pat('cat_card.created')
      redirect url(:cat_cards, :index)
    else
      render 'cat_cards/new'
    end
  end

  get :edit, :with => :id do
    @object = CatCard.get(params[:id])
    render 'cat_cards/edit'
  end

  put :update, :with => :id do
    logger << params.inspect
    @object = CatCard.get(params[:id])
    @object.attributes = params[:cat_card]
    if @deletes.any?                                           # !!!FIXME try and refactore this mess to be as neat as in cat_nodes
      @deletes.each { |k,v| @object.json.delete k }
      @object.save
    end
    if @object.save
      flash[:notice] = pat('cat_card.updated')
      redirect url(:cat_cards, :index)
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
