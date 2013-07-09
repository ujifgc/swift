#coding:utf-8
class Swift::Application < Padrino::Application
  register Padrino::Rendering
  register Padrino::Mailer
  register Padrino::Helpers
  register Swift::Engine

  set :pipeline, {
    :combine => Padrino.env == :production,
    :css => {
      :app => [
        '/stylesheets/libraries/bootstrap-lite.css',
        '/stylesheets/libraries/colorbox.css',
        '/stylesheets/elements/*.css',
        '/stylesheets/app/*.css',
      ]
    },
    :js => {
      :app => [
        '/javascripts/libraries/01-jquery.js',
        '/javascripts/libraries/07-jquery.colorbox.js',
        '/javascripts/elements/*.js',
        '/javascripts/app/*.js',
      ]
    }
  }
  register RackPipeline::Sinatra

  use Rack::Session::DataMapper, :key => 'swift.sid', :path => '/', :secret => 'Dymp1Shnaneu', :expire_after => 1.month

  set :default_builder, 'SwiftFormBuilder'
  set :locales, [ :ru, :en ]

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

  get '/news.xml' do
    content_type 'application/xml'
    @news_articles = NewsArticle.all(:limit => 20, :order => :date.desc).published
    render 'layouts/news'
  end

  # if no controller got the request, try finding some content in the sitemap
  get_or_post = lambda do
    init_swift
    init_page
    not_found  unless @page
    if @page.fragment_id == 'page' && @page.parent_id && @page.text.blank?
      cs = @page.children.all :order => :position
      redirect cs.first.path  if cs.any?
    end
    process_page
  end

  # a trick to consume both get and post requests
  get '/:request_uri', :request_uri => /.*/, &get_or_post
  post '/:request_uri', :request_uri => /.*/, &get_or_post

  # handle 404 and 501 errors
  [404, 501].each do |errno|
    error errno do
      init_swift
      init_error errno
      process_page
    end
  end

end
