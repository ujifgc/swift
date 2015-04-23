Admin.controllers :forms_results do
  set_access :admin, :designer, :auditor

  before :edit, :destroy do
    get_current_object
  end

  get :index do
    filter = {}
    if params[:forms_card_id]
      filter[:forms_card_id] = params[:forms_card_id].to_i  unless params[:forms_card_id] == 'all'
    else
      forms_card = FormsCard.last
      filter[:forms_card_id] = params[:forms_card_id] = forms_card.id  if forms_card
    end
    filter[:order] = :created_at.desc
    @objects = FormsResult.all filter
    render 'forms_results/index'
  end

  before(:edit) { load_protocol_attributes }

  get :edit, :with => :id do
    render 'forms_results/edit'
  end

  delete :destroy, :with => :id do
    if @object.destroy
      flash[:notice] = pat('forms_result.destroyed')
    else
      flash[:error] = pat('forms_result.not_destroyed')
    end
    redirect url(:forms_results, :index)
  end
end
