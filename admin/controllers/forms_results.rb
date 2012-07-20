Admin.controllers :forms_results do

  get :index do
    filter = {}
    filter[:forms_card] = if params[:forms_card].blank?
      FormsCard.first :order => [:created_at.desc]
    else
      FormsCard.by_slug params[:forms_card]
    end
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
