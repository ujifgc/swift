Admin.controllers :fragments do

  before :edit, :update, :destroy do
    @object = Fragment.get(params[:id])
    unless @object
      flash[:error] = pat('object.not_found')
      redirect url(:fragments, :index)
    end
  end

  get :index do
    @basics = Fragment.all :is_fragment => false
    @fragments = Fragment.fragments
    render 'fragments/index'
  end

  get :new do
    @object = Fragment.new
    @code = ''
    render 'fragments/new'
  end

  post :create do
    @code = params[:fragment].delete 'code'
    @object = Fragment.new(params[:fragment])
    if @object.save
      flash[:notice] = pat('fragment.created')
      File.open "#{Swift.root}/views/fragments/_#{@object.id}.haml", 'w', 0644 do |file|
        #file.write "\uFEFF"
        file.write @code.strip + "\n"
      end
      redirect url(:fragments, :index)
    else
      render 'fragments/new'
    end
  end

  get :edit, :with => :id do
    @object = Fragment.get(params[:id])
    @code = begin
      File.open "#{Swift.root}/views/fragments/_#{@object.id}.haml", 'r:bom|utf-8' do |file|
        file.read + "\n"
      end
    rescue
      ''
    end
    render 'fragments/edit'
  end

  put :update, :with => :id do
    @object = Fragment.get(params[:id])
    @code = params[:fragment].delete 'code'
    if @object.update(params[:fragment])
      flash[:notice] = pat('fragment.updated')
      File.open "#{Swift.root}/views/fragments/_#{@object.id}.haml", 'w', 0644 do |file|
        #file.write "\uFEFF"
        file.write @code.strip + "\n"
      end
      redirect url(:fragments, :index)
    else
      render 'fragments/edit'
    end
  end

  delete :destroy, :with => :id do
    @object = Fragment.get(params[:id])
    if @object.destroy
      #File.rm "#{Swift.root}/views/fragments/_#{@object.id}.haml"
      flash[:notice] = pat('fragment.destroyed')
    else
      flash[:error] = pat('fragment.not_destroyed')
    end
    redirect url(:fragments, :index)
  end
end
