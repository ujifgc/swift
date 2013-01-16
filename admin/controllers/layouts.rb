Admin.controllers :layouts do

  before :edit, :update, :destroy do
    @object = Layout.get(params[:id])
    unless @object
      flash[:error] = pat('object.not_found')
      redirect url(:layouts, :index)
    end
  end

  get :index do
    @objects = Layout.all
    render 'layouts/index'
  end

  get :new do
    @object = Layout.new
    render 'layouts/new'
  end

  post :create do
    @code = params[:layout].delete 'code'
    @object = Layout.new(params[:layout])
    if @object.save
      flash[:notice] = pat('layout.created')
      File.open "#{Swift.root}/views/layouts/#{@object.id}.slim", 'w', 0644 do |file|
        file.write @code.strip + "\n"
      end
      redirect url_after_save
    else
      render 'layouts/new'
    end
  end

  get :edit, :with => :id do
    @object = Layout.get(params[:id])
    @code = begin
      File.open "#{Swift.root}/views/layouts/#{@object.id}.slim", "r:bom|utf-8" do |file|
        file.read + "\n"
      end
    rescue
      ''
    end
    render 'layouts/edit'
  end

  put :update, :with => :id do
    @object = Layout.get(params[:id])
    @code = params[:layout].delete 'code'
    if @object.update(params[:layout])
      flash[:notice] = pat('layout.updated')
      File.open "#{Swift.root}/views/layouts/#{@object.id}.slim", 'w', 0644 do |file|
        #file.write "\uFEFF"
        file.write @code.strip + "\n"
      end
      redirect url_after_save
    else
      render 'layouts/edit'
    end
  end

  delete :destroy, :with => :id do
    @object = Layout.get(params[:id])
    if @object.destroy
      #File.rm "#{Swift.root}/views/layouts/#{@object.id}.slim"
      flash[:notice] = pat('layout.destroyed')
    else
      flash[:error] = pat('layout.not_destroyed')
    end
    redirect url(:layouts, :index)
  end
end
