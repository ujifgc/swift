#coding:utf-8
class Swift::Application < Padrino::Application
  register Padrino::Rendering
  register Padrino::Mailer
  register Padrino::Helpers
  register Sinatra::AssetPack
  register Swift::Engine

  assets do
    serve '/stylesheets', from: '../assets/stylesheets'
    serve '/javascripts', from: '../assets/javascripts'

    js_compression :simple

    css :app, [
      '/stylesheets/libraries/bootstrap-lite.css',
      '/stylesheets/libraries/colorbox.css',
      '/stylesheets/elements/*.css',
      '/stylesheets/app/*.css',
    ]

    js :app, [
      '/javascripts/libraries/01-jquery.js',
      '/javascripts/libraries/07-jquery.colorbox.js',
      '/javascripts/elements/*.js',
      '/javascripts/app/*.js',
    ]
  end

  use Rack::Session::DataMapper, :key => 'swift.sid', :path => '/', :secret => 'Dymp1Shnaneu', :expire_after => 1.month

  set :default_builder, 'SwiftFormBuilder'
  set :locales, [ :ru, :en ]

  `which /usr/sbin/exim` #!!! FIXME this is bullcrap
  if $?.success?
    set :delivery_method, :smtp
  else
    set :delivery_method, :sendmail
  end

  # if web server can't statically serve image request, regenerate the image version
  # and tell browser to lurk again with new timestamp
  get '/cache/:version/:model/:id/*' do
    model = params[:model].constantize  rescue nil
    error 400  unless model
    object = model.get params[:id]  rescue nil
    error 404  unless object
    url = object.file.versions[params[:version].to_sym].url  rescue nil
    error 400  unless url
    filename = object.file.render!( params[:version].to_sym ).url
    redirect filename + asset_timestamp(filename)
  end

  get '/sitemap.xml' do
    content_type 'application/xml'
    @pages = Page.all.published
    render 'layouts/sitemap'
  end

  get '/rss' do
    content_type 'application/xml'
    @news_articles = NewsArticle.all(:limit => 20, :order => :date.desc).published
    render 'layouts/news'
  end

  get '/news.xml' do
    redirect '/rss'
  end

  # if no controller got the request, try finding some content in the sitemap
  get_or_post = lambda do
    init_instance
    not_found  unless @page
    if @page.fragment_id == 'page' && @page.parent_id && @page.text.blank?
      cs = @page.children.all :order => :position
      redirect cs.first.path  if cs.any?
    end
    params.reverse_merge! Rack::Utils.parse_query(@page.params)  unless @page.params.blank?
    process_page
  end

  # a trick to consume both get and post requests
  get '/:request_uri', :request_uri => /.*/, &get_or_post
  post '/:request_uri', :request_uri => /.*/, &get_or_post

  # handle 404 and 501 errors
  [404, 501].each do |errno|
    error errno do
      path = "/error/#{errno}"
      @page = Page.first :path => path
      @page ? process_page : "error page '#{path}' not found"
    end
  end

protected

  def init_instance
    swift[:path_pages] = []
    swift[:path_ids] = []
    swift[:method] = request.env['REQUEST_METHOD']
    swift[:placeholders] = {}
    swift[:host] = request.env['SERVER_NAME']
    swift[:uri] = "/#{params[:request_uri]}"
    swift[:path] = swift[:uri].partition('?').first

    path = swift[:path]
    path = path.chomp('/')  if path.length > 1
    page = Page.first( :conditions => [ "? LIKE IF(is_module,CONCAT(path,'%'),path)", path ], :order => :path.desc )

    if page && page.is_module
      swift[:module_root] = page.path  # => /news
      swift[:slug] = case path[page.path.length]
      when '/'  # /news/some-slug
        path[(page.path.length+1)..-1] # => some-slug
      when nil  # /news
        ''
      else      # /newsbar
        page = nil
      end
    end

    unless page
      root = Page.first( :parent => nil )
      swift[:path_pages].unshift root
      swift[:path_ids].unshift root.id
    end
    
    swift[:resource] = page
    @page = page

    while page
      swift[:path_pages].unshift page
      swift[:path_ids].unshift page.id
      page = page.parent
    end
  end

end
