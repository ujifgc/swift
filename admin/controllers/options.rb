Admin.controllers :options do
  set_access :admin

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
    val = params[:option].delete 'value'
    params[:option]['value'] = begin
      eval(val)
    rescue Exception
      val
    end

    @object = Option.new(params[:option])
    if @object.save
      flash[:notice] = pat('option.created')
      redirect url_after_save
    else
      render 'options/new'
    end
  end

  before(:edit) { load_protocol_attributes }

  get :edit, :with => :id do
    render 'options/edit'
  end

  put :update, :with => :id do
    val = params[:option].delete 'value'
    params[:option]['value'] = begin
      eval(val)
    rescue Exception
      val
    end
    
    if @object.update(params[:option])
      flash[:notice] = pat('option.updated')
      redirect url_after_save
    else
      render 'options/edit'
    end
  end

  delete :destroy, :with => :id do
    if @object.destroy
      flash[:notice] = pat('option.destroyed')
    else
      flash[:error] = pat('option.not_destroyed')
    end
    redirect url(:options, :index)
  end
end
