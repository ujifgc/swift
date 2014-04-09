Admin.controllers :cat_nodes do
  set_access :admin, :designer, :auditor, :editor

  before :edit, :update, :destroy do
    @object = CatNode.get(params[:id])
    unless @object
      flash[:error] = pat('object.not_found')
      redirect url(:cat_nodes, :index)
    end
  end

  before :create, :update do
    node = params[:cat_node]
    card = @object && @object.cat_card || CatCard.get(node['cat_card_id'])
    @assets = []
    card.json_of_type(:assets).each do |k,v|
      files = node[k]
      files = [files] unless files.kind_of? Array
      files = files.inject([]) do |all,data|
        if data.kind_of?(String)
          begin
            data = MultiJson.decode(data)
          rescue JSON::ParserError
          end
        end
        data = nil if data.blank?
        all += data.kind_of?(Array) ? data : [data]
      end
      assets = files.uniq.map do |file|
        case file
        when Hash
          Asset.create(
            :title => file[:filename],
            :file => file,
            :folder => card.folder,
          )
        else
          Asset.get(file)
        end
      end.compact
      if assets.any?
        params[:cat_node][k] = assets.map(&:id)
        @assets += assets
      end
    end
    
    params[:cat_node]['title'] = File.basename(@assets.first.title, '.*') if params[:cat_node]['title'].blank? && @assets.any?
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
    @object = CatNode.new(params[:cat_node])
    card = CatCard.get(session[:cat_card_id]) if session[:cat_card_id]
    @object.cat_card ||= card || CatCard.last
    render 'cat_nodes/new'
  end

  post :create do
    @object = CatNode.new(params[:cat_node])
    session[:cat_card_id] = @object.cat_card_id
    if @object.save
      flash[:notice] = pat('cat_node.created')
      redirect url_after_save
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
        when 'images'
          value = begin
            v.kind_of?(String) ? MultiJson.decode(v) : v
          rescue JSON::ParserError
            v
          end
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
