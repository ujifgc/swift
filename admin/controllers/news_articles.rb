Admin.controllers :news_articles do

  get :index do
    @objects = NewsArticle.all
    render 'news_articles/index'
  end

  get :new do
    @object = NewsArticle.new
    render 'news_articles/new'
  end

  post :create do
    @object = NewsArticle.new(params[:news_article])
    if @object.save
      flash[:notice] = pat('news_article.created')
      redirect url(:news_articles, :index)
    else
      render 'news_articles/new'
    end
  end

  get :edit, :with => :id do
    @object = NewsArticle.get(params[:id])
    render 'news_articles/edit'
  end

  put :update, :with => :id do
    @object = NewsArticle.get(params[:id])
    if @object.update(params[:news_article])
      flash[:notice] = pat('news_article.updated')
      redirect url(:news_articles, :index)
    else
      render 'news_articles/edit'
    end
  end

  delete :destroy, :with => :id do
    @object = NewsArticle.get(params[:id])
    if @object.destroy
      flash[:notice] = pat('news_article.destroyed')
    else
      flash[:error] = pat('news_article.not_destroyed')
    end
    redirect url(:news_articles, :index)
  end
end
