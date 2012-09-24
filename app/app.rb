#coding:utf-8
STATIC_FOLDERS = %W(doc images img)

class Swift < Padrino::Application
  register Padrino::Rendering
  register Padrino::Mailer
  register Padrino::Helpers

  enable :sessions

  register Padrino::Sprockets
  sprockets

  set :default_builder, 'SwiftFormBuilder'

  before do
    @swift = init_instance
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

  # if no controller got the request, try finding some content in the sitemap
  get_or_post = lambda do
    not_found  unless @page

    if @page.fragment_id == 'page' && @page.parent_id && @page.text.blank?
      cs = @page.children.all :order => :position
      redirect cs.first.path  if cs.any?
    end

    @page.text = render_text @page.text
    params.reverse_merge! Rack::Utils.parse_query(@page.params)  unless @page.params.blank?
    begin
      render 'fragments/_' + @page.fragment_id, :layout => @page.layout_id
    rescue Padrino::Rendering::TemplateNotFound => err
      "[Template ##{@page.fragment_id} missing]"
    end
  end

  # a trick to consume both get and post requests
  get '/*', &get_or_post
  post '/*', &get_or_post

  # if the sitemap does not have the requested page then show the 404
  not_found do
    @page = Page.first :path => '/error/404'
    @page.text = render_text @page.text
    render 'fragments/_' + @page.fragment_id, :layout => @page.layout_id
  end

  # requested wrong service or wrong parameters
  error 501 do
    @page = Page.first :path => '/error/501'
    @page.text = render_text @page.text
    render 'fragments/_' + @page.fragment_id, :layout => @page.layout_id
  end

protected

  def init_instance
    halt 403  if STATIC_FOLDERS.include?( request.env['PATH_INFO'].split('/')[1] )

    swift = {}
    swift[:path_pages] = []
    swift[:path_ids] = []
    swift[:method] = request.env['REQUEST_METHOD']

    path = request.env['PATH_INFO']
    path = path.gsub( /(.+)\/$/, '\1' )  if path.length > 1
    swift[:uri] = path
    path = path.gsub /\/\d+/, ''
    page = Page.first( :conditions => [ "? LIKE IF(is_module,CONCAT(path,'%'),path)", path ], :order => :path.desc )
    @page = page

    if page && path.length >= page.path.length
      swift[:slug] = path.gsub /^#{page.path}/, ''
      swift[:module_root] = page.path
      case swift[:slug][0]
      when nil
        nil
      when '/'
        swift[:slug] = swift[:slug][1..-1]
      else
        not_found
      end
    end

    while page
      swift[:path_pages].unshift page
      swift[:path_ids].unshift page.id
      page = page.parent
    end

    swift
  end

end
