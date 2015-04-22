Admin.controllers :news_rubrics do
  set_access :admin, :designer, :auditor

  before :edit, :update, :destroy do
    @object = NewsRubric.get(params[:id])
    unless @object
      flash[:error] = pat('object.not_found')
      redirect url(:news_rubrics, :index)
    end
  end

  get :index do
    @objects = NewsRubric.all
    render 'news_rubrics/index'
  end

  get :new do
    @object = NewsRubric.new
    render 'news_rubrics/new'
  end

  post :create do
    @object = NewsRubric.new(params[:news_rubric])
    if @object.save
      flash[:notice] = pat('news_rubric.created')
      redirect url_after_save
    else
      render 'news_rubrics/new'
    end
  end

  before(:edit) { load_protocol_attributes }

  get :edit, :with => :id do
    render 'news_rubrics/edit'
  end

  put :update, :with => :id do
    if @object.update(params[:news_rubric])
      flash[:notice] = pat('news_rubric.updated')
      redirect url_after_save
    else
      render 'news_rubrics/edit'
    end
  end

  delete :destroy, :with => :id do
    if @object.destroy
      flash[:notice] = pat('news_rubric.destroyed')
    else
      flash[:error] = pat('news_rubric.not_destroyed')
    end
    redirect url(:news_rubrics, :index)
  end
end
