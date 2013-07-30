#coding:utf-8
class Swift::Application < Padrino::Application
  register Padrino::Helpers
  register Swift::Engine
  use Rack::Session::File

  set :default_builder, 'SwiftFormBuilder'
  set :locales, [ :ru, :en ]
  set :pipeline, {
    :combine => Padrino.env == :production,
    :css => {
      :app => [
        'vendor/stylesheets/libraries/bootstrap-lite.css',
        'vendor/stylesheets/libraries/colorbox.css',
        'assets/stylesheets/elements/*.css',
        'assets/stylesheets/app/*.css',
      ]
    },
    :js => {
      :app => [
        'vendor/javascripts/libraries/01-jquery.js',
        'vendor/javascripts/libraries/07-jquery.colorbox.js',
        'assets/javascripts/elements/*.js',
        'assets/javascripts/app/*.js',
      ]
    }
  }
  register RackPipeline::Sinatra

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
    render :slim, :'layouts/sitemap.xml', :format => :xhtml
  end

  get '/news.xml' do
    content_type 'application/xml'
    @news_articles = NewsArticle.all(:limit => 20, :order => :date.desc).published
    render :slim, :'layouts/news.xml', :format => :xhtml
  end

  # if no controller got the request, try finding some content in the sitemap
  get_or_post = lambda do
    init_swift
    init_page  or not_found
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
