Admin.controllers :news_articles do
  set_access :admin, :designer, :auditor, :editor

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

    if params[:news_rubric_id]
      filter[:news_rubric_id] = params[:news_rubric_id].to_i  unless params[:news_rubric_id] == 'all'
    else
      news_article = NewsArticle.last
      filter[:news_rubric_id] = params[:news_rubric_id] = news_article.news_rubric.id  if news_article && news_article.news_rubric
    end

    if params[:title].present?
      filter[:title.like] = '%' + params[:title] + '%'
    end

    @count = NewsArticle.count filter

    @per_page = (params[:per_page] || Option(:per_page)).to_i
    @per_page = 20  if @per_page < 1
    @total_pages = (@count - 1) / @per_page + 1
    @current_page = (params[:page] || 1).to_i
    @current_page = 1  if @current_page < 1
    filter.merge!( {
      limit: @per_page,
      offset: (@current_page - 1) * @per_page,
    } )

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
