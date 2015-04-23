Admin.controllers :layouts do
  set_access :admin, :designer

  before :edit, :update, :destroy do
    get_current_object
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
      File.open "#{Swift::Application.views}/layouts/#{@object.id}.slim", 'w', 0644 do |file|
        file.write @code.strip + "\n"
      end
      redirect url_after_save
    else
      render 'layouts/new'
    end
  end

  before(:edit) { load_protocol_attributes }

  get :edit, :with => :id do
    @code = begin
      File.open "#{Swift::Application.views}/layouts/#{@object.id}.slim", "r:bom|utf-8" do |file|
        file.read + "\n"
      end
    rescue
      ''
    end
    render 'layouts/edit'
  end

  put :update, :with => :id do
    @code = params[:layout].delete 'code'
    if @object.update(params[:layout])
      flash[:notice] = pat('layout.updated')
      File.open "#{Swift::Application.views}/layouts/#{@object.id}.slim", 'w', 0644 do |file|
        #file.write "\uFEFF"
        file.write @code.strip + "\n"
      end
      redirect url_after_save
    else
      render 'layouts/edit'
    end
  end

  delete :destroy, :with => :id do
    if @object.destroy
      #File.rm "#{Swift::Application.views}/layouts/#{@object.id}.slim"
      flash[:notice] = pat('layout.destroyed')
    else
      flash[:error] = pat('layout.not_destroyed')
    end
    redirect url(:layouts, :index)
  end
end
