Admin.controllers :news_articles do

  before :edit, :update, :destroy do
    @object = NewsArticle.get(params[:id])
    unless @object
      flash[:error] = pat('object.not_found')
      redirect url(:news_articles, :index)
    end
  end

  before :create, :update do
    create_event = params[:news_article].delete('has_event')
    if create_event
      durc = params[:news_article].delete( 'duration_count' ).to_i
      duru = params[:news_article].delete( 'duration_units' )
      event_attributes = params[:news_article].reject{|k,v|k=='publish_at'}
      event_attributes[:duration] = "#{durc}.#{duru}"
      unless NewsEvent.by_slug(params[:news_article]['slug'])
        @new_event = NewsEvent.create(event_attributes)
      end
    end
  end

  get :index do
    filter = { :order => [ :date.desc, :created_at.desc ] }
    filter[:news_rubric_id] = params[:news_rubric_id].to_i  if params[:news_rubric_id]
    @count = NewsArticle.count filter
    if @count > 100
      @per_page = 25
      @pagenum = (@count - 1) / @per_page + 1
      @page = params[:page].to_i > 0 ? params[:page].to_i : 1
      filter.merge! :limit => @per_page, :offset => (@page - 1)*@per_page
    end
    @objects = NewsArticle.all filter
    render 'news_articles/index'
  end

  get :new do
    #info = {:date => Date.today}
    @object = NewsArticle.new :date => Date.today, :publish_at => Date.today
    
    render 'news_articles/new'
  end

  post :create do
    @object = NewsArticle.new(params[:news_article])
    if @object.save
      flash[:notice] = pat('news_article.created')
      redirect url_after_save
    else
      render 'news_articles/new'
    end
    
  end

  get :edit, :with => :id do
    render 'news_articles/edit'
  end

  put :update, :with => :id do
    if @object.update(params[:news_article])
      flash[:notice] = pat('news_article.updated')
      redirect url_after_save
    else
      render 'news_articles/edit'
    end
  end

  delete :destroy, :with => :id do
    if @object.destroy
      flash[:notice] = pat('news_article.destroyed')
    else
      flash[:error] = pat('news_article.not_destroyed')
    end
    redirect url(:news_articles, :index)
  end
end
