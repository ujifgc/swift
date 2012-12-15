Admin.controllers :options do

  before :edit, :update, :destroy do
    @object = Option.get(params[:id])
    unless @object
      flash[:error] = pat('object.not_found')
      redirect url(:options, :index)
    end
  end

  get :index do
    @objects = Option.all
    render 'options/index'
  end

  get :new do
    @object = Option.new
    render 'options/new'
  end

  post :create do
    @object = Option.new(params[:option])
    if @object.save
      flash[:notice] = pat('option.created')
      redirect url(:options, :index)
    else
      render 'options/new'
    end
  end

  get :edit, :with => :id do
    @object = Option.get(params[:id])
    render 'options/edit'
  end

  put :update, :with => :id do
    @object = Option.get(params[:id])
    if @object.update(params[:option])
      flash[:notice] = pat('option.updated')
      redirect url(:options, :index)
    else
      render 'options/edit'
    end
  end

  delete :destroy, :with => :id do
    @object = Option.get(params[:id])
    if @object.destroy
      flash[:notice] = pat('option.destroyed')
    else
      flash[:error] = pat('option.not_destroyed')
    end
    redirect url(:options, :index)
  end
end
