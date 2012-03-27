#coding:utf-8
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

    @page = Page.new :title => 'Default title'
  end

  # if no controller got the request, try finding some content in the sitemap
  get '/*' do
    path = request.env['PATH_INFO'].gsub( /(.+)\/$/, '\1' )
    if @page = Page.first( :conditions => [ '? LIKE path', path ] )
      if @page.fragment_id == 'page' && @page.text.blank?
        cs = @page.children.all :order => :position
        redirect cs.first.path  if cs.any?
      end # !!!FIXME this feels like bad redirect
      @page.text = parse_uub( @page.text ).html
      #params.reverse_merge!  !!!FIXME add page parameters
      render 'fragments/_' + @page.fragment_id, :layout => @page.layout_id
    else
      not_found
    end
  end

  # if the sitemap does not have the requested page then show the 404
  not_found do
    @page = Page.first :path => '/error/404'
    @page.text = parse_uub( @page.text ).html
    render 'fragments/_' + @page.fragment_id, :layout => @page.layout_id
  end

  # requested wrong service or wrong parameters
  error 501 do
    @page = Page.first :path => '/error/501'
    @page.text = parse_uub( @page.text ).html
    render 'fragments/_' + @page.fragment_id, :layout => @page.layout_id
  end

end
