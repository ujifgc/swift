Admin.controllers :pages do

  get :index do
    @tree = page_tree( nil, 0, '' )
    render 'pages/index'
  end

  get :new do
    @object = Page.new
    render 'pages/new'
  end

  post :create do
    @object = Page.new(params[:page])
    if @object.save
      flash[:notice] = pat('page.created')
      redirect url(:pages, :index)
    else
      render 'pages/new'
    end
  end

  get :edit, :with => :id do
    @object = Page.get(params[:id])
    render 'pages/edit'
  end

  put :update, :with => :id do
    @object = Page.get(params[:id])
    if @object.update(params[:page])
      flash[:notice] = pat('page.updated')
      redirect params[:apply] ? back : url(:pages, :index)
    else
      render 'pages/edit'
    end
  end

  post :reposition, :with => [:id, :direction] do
    @object = Page.get(params[:id])
    if @object
      @object.reposition! params[:direction]
      flash[:notice] = pat('page.repositioned')
    else
      flash[:notice] = pat('page.not_found')
    end
    redirect url(:pages, :index)
  end

  delete :destroy, :with => :id do
    @object = Page.get(params[:id])
    if @object.destroy
      flash[:notice] = pat('page.destroyed')
    else
      flash[:error] = pat('page.not_destroyed')
    end
    redirect url(:pages, :index)
  end

end
