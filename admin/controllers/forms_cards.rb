Admin.controllers :forms_cards do
  get :index do
    @objects = FormsCard.all
    render 'forms_cards/index'
  end

  get :new do
    @object = FormsCard.new
    render 'forms_cards/new'
  end

  post :create do
    @object = FormsCard.new(params[:forms_card])
    @object.fill_json params, :forms_results
    if @object.save
      flash[:notice] = pat('forms_card.created')
      redirect url(:forms_cards, :index)
    else
      render 'forms_cards/new'
    end
  end

  get :edit, :with => :id do
    @object = FormsCard.get(params[:id])
    render 'forms_cards/edit'
  end

  put :update, :with => :id do
    @object = FormsCard.get(params[:id])
    @object.attributes = params[:forms_card]
    @object.fill_json params, :forms_results
    if @object.save
      flash[:notice] = pat('forms_card.updated')
      redirect url(:forms_cards, :index)
    else
      render 'forms_cards/edit'
    end
  end

  delete :destroy, :with => :id do
    @object = FormsCard.get(params[:id])
    if @object.destroy
      flash[:notice] = pat('forms_card.destroyed')
    else
      flash[:error] = pat('forms_card.not_destroyed')
    end
    redirect url(:forms_cards, :index)
  end
end
