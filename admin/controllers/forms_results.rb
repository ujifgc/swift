Admin.controllers :forms_results do

  before :edit, :update, :destroy do
    @object = FormsResult.get(params[:id])
    unless @object
      flash[:error] = pat('object.not_found')
      redirect url(:forms_results, :index)
    end
  end

  get :index do
    filter = {}
    card_id = params[:forms_card].blank? ? FormsCard.first( :order => [:created_at.desc] ).id : FormsCard.by_slug( params[:forms_card] ).id  rescue nil
    filter[:forms_card_id] = card_id  if card_id
    @objects = FormsResult.all filter
    render 'forms_results/index'
  end

  get :new do
    @object = FormsResult.new
    render 'forms_results/new'
  end

  post :create do
    @object = FormsResult.new(params[:forms_result])
    if @object.save
      flash[:notice] = pat('forms_result.created')
      redirect url(:forms_results, :index)
    else
      render 'forms_results/new'
    end
  end

  get :edit, :with => :id do
    @object = FormsResult.get(params[:id])
    render 'forms_results/edit'
  end

  put :update, :with => :id do
    @object = FormsResult.get(params[:id])
    if @object.update(params[:forms_result])
      flash[:notice] = pat('forms_result.updated')
      redirect url(:forms_results, :index)
    else
      render 'forms_results/edit'
    end
  end

  delete :destroy, :with => :id do
    @object = FormsResult.get(params[:id])
    if @object.destroy
      flash[:notice] = pat('forms_result.destroyed')
    else
      flash[:error] = pat('forms_result.not_destroyed')
    end
    redirect url(:forms_results, :index)
  end
end
