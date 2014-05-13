Admin.controllers :forms_faqs do
  set_access :admin, :designer, :auditor, :editor

  before :edit, :update, :destroy do
    @object = FormsFaq.get(params[:id])
    unless @object
      flash[:error] = pat('object.not_found')
      redirect url(:forms_faqs, :index)
    end
  end

  get :index do
    @objects = FormsFaq.all
    render 'forms_faqs/index'
  end

  get :new do
    @object = FormsFaq.new
    render 'forms_faqs/new'
  end

  post :create do
    @object = FormsFaq.new(params[:forms_faq])
    if @object.save
      flash[:notice] = pat('forms_faq.created')
      redirect url_after_save
    else
      render 'forms_faqs/new'
    end
  end

  get :edit, :with => :id do
    @object = FormsFaq.get(params[:id])
    render 'forms_faqs/edit'
  end

  put :update, :with => :id do
    @object = FormsFaq.get(params[:id])
    if @object.update(params[:forms_faq])
      flash[:notice] = pat('forms_faq.updated')
      redirect url_after_save
    else
      render 'forms_faqs/edit'
    end
  end

  delete :destroy, :with => :id do
    @object = FormsFaq.get(params[:id])
    if @object.destroy
      flash[:notice] = pat('forms_faq.destroyed')
    else
      flash[:error] = pat('forms_faq.not_destroyed')
    end
    redirect url(:forms_faqs, :index)
  end
end
