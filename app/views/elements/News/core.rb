if md = @swift[:slug].match( /show\/(.*)/ )
  @swift[:skip_view]['News'] = true
  @swift[:slug] = md[1]
  @swift[:path_pages] << Page.new
  return element( 'NewsArticle', @args, @opts )
end
