Admin.controllers :news_events do

  before :update, :create do
    durc = params[:news_event].delete( 'duration_count' ).to_i
    duru = params[:news_event].delete( 'duration_units' )
    if NewsEvent::Durations.has_value? duru
      params[:news_event]['duration'] = "#{durc}.#{duru}"
    end
  end

  before :edit, :update, :destroy do
    @object = NewsEvent.get(params[:id])
    unless @object
      flash[:error] = pat('object.not_found')
      redirect url(:news_events, :index)
    end
  end

  get :index do
    @objects = NewsEvent.all
    render 'news_events/index'
  end

  get :new do
    @object = NewsEvent.new
    render 'news_events/new'
  end

  post :create do
    @object = NewsEvent.new(params[:news_event])
    if @object.save
      flash[:notice] = pat('news_event.created')
      redirect url(:news_events, :index)
    else
      render 'news_events/new'
    end
  end

  get :edit, :with => :id do
    @object = NewsEvent.get(params[:id])
    render 'news_events/edit'
  end

  put :update, :with => :id do
    @object = NewsEvent.get(params[:id])
    if @object.update(params[:news_event])
      flash[:notice] = pat('news_event.updated')
      redirect url(:news_events, :index)
    else
      render 'news_events/edit'
    end
  end

  delete :destroy, :with => :id do
    @object = NewsEvent.get(params[:id])
    if @object.destroy
      flash[:notice] = pat('news_event.destroyed')
    else
      flash[:error] = pat('news_event.not_destroyed')
    end
    redirect url(:news_events, :index)
  end
end
