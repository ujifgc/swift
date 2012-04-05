Admin.controllers :cat_groups do

  get :index do
    @objects = CatGroup.all :order => :path
    render 'cat_groups/index'
  end

  get :new do
    @object = CatGroup.new
    render 'cat_groups/new'
  end

  post :create do
    @object = CatGroup.new(params[:cat_group])
    if @object.save
      flash[:notice] = pat('cat_group.created')
      redirect url(:cat_groups, :edit, :id => @object.id)
    else
      render 'cat_groups/new'
    end
  end

  get :edit, :with => :id do
    @object = CatGroup.get(params[:id])
    render 'cat_groups/edit'
  end

  put :update, :with => :id do
    @object = CatGroup.get(params[:id])
    fields = {}
    @object.cat_card.json.keys.each do |key|
      fields[key] = params[:cat_group].delete(key)
    end
    @object.attributes = params[:cat_group]
    fields.each do |k,v|
      if v.blank?
        @object.json.delete k
      else
        @object.json[k] = v
      end
    end
    if @object.save
      flash[:notice] = pat('cat_group.updated')
      redirect url(:cat_groups, :index)
    else
      render 'cat_groups/edit'
    end
  end

  delete :destroy, :with => :id do
    @object = CatGroup.get(params[:id])
    if @object.destroy
      flash[:notice] = pat('cat_group.destroyed')
    else
      flash[:error] = pat('cat_group.not_destroyed')
    end
    redirect url(:cat_groups, :index)
  end
end
