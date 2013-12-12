Admin.controllers :cat_nodes do

  before :edit, :update, :destroy do
    @object = CatNode.get(params[:id])
    unless @object
      flash[:error] = pat('object.not_found')
      redirect url(:cat_nodes, :index)
    end
  end

  get :index do
    @objects = CatNode.all
    filter = {}
    if params[:card_id]
      filter[:card_id] = params[:card_id].to_i  unless params[:card_id] == 'all'
    else
      cat_card = CatCard.last
      filter[:card_id] = params[:card_id] = cat_card.id  if cat_card
    end
    @card = CatCard.get filter[:card_id]
    @groups = @card ? CatGroup.all( :cat_card_id => @card.id ) : []
    @group = CatGroup.get params[:group_id].to_i
    @objects = @objects.filter_by(@card).filter_by(@group)
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
      redirect url(:cat_nodes, :edit, :id => @object.id) #!!! FIXME should load actual fields on :new, maybe xhr
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
    attributes = {}
    params[:cat_node].each do |k,v|
      if card_field = @object.cat_card.json[k]
        case card_field[0]
        when 'assets', 'images'
          value = MultiJson.load(v)  rescue nil
          attributes[k] = value  if value
        when "number"
          attributes[k] = v.to_i
        else
          attributes[k] = v
        end
      else
        attributes[k] = v
      end
    end
    if @object.update(attributes)
      flash[:notice] = pat('cat_node.updated')
      redirect url_after_save
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
