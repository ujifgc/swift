Admin.controllers :news_rubrics do

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
      redirect url(:news_rubrics, :index)
    else
      render 'news_rubrics/new'
    end
  end

  get :edit, :with => :id do
    @object = NewsRubric.get(params[:id])
    render 'news_rubrics/edit'
  end

  put :update, :with => :id do
    @object = NewsRubric.get(params[:id])
    if @object.update(params[:news_rubric])
      flash[:notice] = pat('news_rubric.updated')
      redirect url(:news_rubrics, :index)
    else
      render 'news_rubrics/edit'
    end
  end

  delete :destroy, :with => :id do
    @object = NewsRubric.get(params[:id])
    if @object.destroy
      flash[:notice] = pat('news_rubric.destroyed')
    else
      flash[:error] = pat('news_rubric.not_destroyed')
    end
    redirect url(:news_rubrics, :index)
  end
end
