Admin.controllers :pages do

  get :index do
    @objects = Page.all :order => :path
    render 'pages/index'
  end

  get :new do
    @object = Page.new
    render 'pages/new'
  end

  post :create do
    @object = Page.new(params[:page])
    if @object.save
      flash[:notice] = pat("#{@model}.created")
      redirect url(:pages, :edit, :id => @object.id)
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
      flash[:notice] = 'Page was successfully updated.'
      redirect url(:pages, :edit, :id => @object.id)
    else
      render 'pages/edit'
    end
  end

  delete :destroy, :with => :id do
    @object = Page.get(params[:id])
    if page.destroy
      flash[:notice] = 'Page was successfully destroyed.'
    else
      flash[:error] = 'Unable to destroy Page!'
    end
    redirect url(:pages, :index)
  end
end
