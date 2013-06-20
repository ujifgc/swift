#coding:utf-8
STATIC_FOLDERS = %W(doc images img stylesheets javascripts)

class Swift < Padrino::Application
  register Padrino::Rendering
  register Padrino::Mailer
  register Padrino::Helpers
  register Sinatra::AssetPack

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

  helpers Padrino::Helpers::EngineHelpers

  use Rack::Session::DataMapper, :key => 'swift.sid', :path => '/', :secret => 'Dymp1Shnaneu', :expire_after => 1.month

  set :default_builder, 'SwiftFormBuilder'

  `which /usr/sbin/exim` #!!! FIXME this is bullcrap
  if $?.success?
    set :delivery_method, :smtp
  else
    set :delivery_method, :sendmail
  end

  # serve assets with AssetPack

  # if web server can't statically serve image request, regenerate the image outlet
  # and tell browser to lurk again with new timestamp
  get '/cache/:model/:id@:outlet-:file' do
    model = params[:model].constantize  rescue nil
    error 400  unless model
    object = model.get params[:id]  rescue nil
    error 404  unless object
    outlet = object.file.outlets[params[:outlet].to_sym]  rescue nil
    error 400  unless outlet
    outlet.prepare!
    error 503  unless File.exists?(outlet.path)
    result = outlet.url
    redirect result + asset_timestamp(result)
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
    @swift = init_instance
    not_found  if @swift[:not_found]
    not_found  unless @page

    if @page.fragment_id == 'page' && @page.parent_id && @page.text.blank?
      cs = @page.children.all :order => :position
      redirect cs.first.path  if cs.any?
    end

    params.reverse_merge! Rack::Utils.parse_query(@page.params)  unless @page.params.blank?

    inject_placeholders fragment @page.fragment_id, :layout => @page.layout_id
  end

  # a trick to consume both get and post requests
  get '/*', &get_or_post
  post '/*', &get_or_post

  # if the sitemap does not have the requested page then show the 404
  not_found do
    @page = Page.first :path => '/error/404'
    inject_placeholders fragment @page.fragment_id, :layout => @page.layout_id
  end

  # requested wrong service or wrong parameters
  error 501 do
    @page = Page.first :path => '/error/501'
    inject_placeholders fragment @page.fragment_id, :layout => @page.layout_id
  end

protected

  def init_instance
    halt 403  if STATIC_FOLDERS.include?( request.env['PATH_INFO'].split('/')[1] )

    # detecting of locale preferred by browser
    session[:locale] ||= request.env['HTTP_ACCEPT_LANGUAGE'].gsub(/\s+/,'').split(/,/)
                         .sort_by{ |tags| -(tags.partition(/;/).last.split(/=/)[1]||1).to_f }
                         .first  rescue 'ru'
    session[:locale] = params[:locale]  if params[:locale]
    I18n.locale = :ru #session[:locale][0..1].to_sym # !!! FIXME might need full format for en_US and en_GB distinction

    swift = {}
    swift[:path_pages] = []
    swift[:path_ids] = []
    swift[:method] = request.env['REQUEST_METHOD']
    swift[:placeholders] = {}
    swift[:uri] = request.env['REQUEST_URI']
    swift[:host] = request.env['SERVER_NAME']
    swift[:path] = request.env['PATH_INFO']

    path = swift[:path]
    path = path.chomp('/')  if path.length > 1
    page = Page.first( :conditions => [ "? LIKE IF(is_module,CONCAT(path,'%'),path)", path ], :order => :path.desc )
    @page = page

    if page && path.length >= page.path.length
      swift[:slug] = path.gsub /^#{page.path}/, ''
      swift[:module_root] = page.path
      # !!! FIXME this if-else block is madness
      if page.is_module || page.published?
        case swift[:slug][0]
        when nil
          swift[:slug] = ''
        when '/'
          swift[:slug] = swift[:slug][1..-1]
        else
          swift[:not_found] = true  #FIXME
        end
      else
        swift[:not_found] = true  #FIXME
      end
    end

    unless page
      root = Page.first( :parent => nil )
      swift[:path_pages].unshift root
      swift[:path_ids].unshift root.id
    end
    
    while page
      swift[:path_pages].unshift page
      swift[:path_ids].unshift page.id
      page = page.parent
    end

    swift
  end

end
