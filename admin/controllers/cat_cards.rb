#
Admin.controllers :cat_cards do
  before :create, :update do
    @keys = params.delete 'key'
    @types = params.delete 'type'
    @values = params.delete 'value'
    @adds = []
    @rest = []
    @deletes = []
    @renames = {}
    @keys.each do |k,v|
      if @types[k] == "" || v.blank?
        @deletes << k
        next
      end
      if k.match(/cat_node_new-\d+/)
        @adds << k
        next
      end
      if k != v
        @renames.merge! k => v
        next
      end
      @rest << k
    end
    logger << [@adds, @rest, @deletes, @renames].inspect
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
    @object = CatCard.get(params[:id])
    @object.attributes = params[:cat_card]
    logger << @object.json.inspect
    @deletes.each do |k|
      @object.json.delete k
    end
    if @renames.any? #!!! FIXME add routines to rename all fields in data store, also add bulk rename of :select value renames (or just alert the user)
      @object.json = Hash[@object.json.map{ |k,v| @renames[k] ? [@renames[k], [@types[k], @values[k]]] : [k, v] }]
    end
    (@adds+@rest).each do |k|
      @object.json[@keys[k]] = [@types[k], @values[k]]
    end
    logger << @object.json.inspect
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
