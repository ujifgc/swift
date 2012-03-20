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
    logger << "\n\n---\n"

    @swift = init_instance

    @page = Page.new :title => 'Default title'
  end

  # if no controller got the request, try finding some content in the sitemap
  # if the sitemap does not have the requested page then show the real 404
  not_found do
    if @page = Page.first( :path => request.env['PATH_INFO'].gsub( /(.+)\/$/, '\1' ) )
      @page.text = parse_uub( @page.text ).html
      #params.reverse_merge!  !!!FIXME
      response.body = render 'fragments/_' + @page.fragment_id, :layout => @page.layout_id
      halt 200
    else
      @page = Page.first :path => '/error/404'
      @page.text = parse_uub( @page.text ).html
      response.body = render 'fragments/_' + @page.fragment_id, :layout => @page.layout_id
      halt 404
    end
  end

  # requested wrong service or wrong parameters
  error 501 do
    @page = Page.first :path => '/error/501'
    @page.text = parse_uub( @page.text ).html
    render 'fragments/_' + @page.fragment_id, :layout => @page.layout_id
  end

end
