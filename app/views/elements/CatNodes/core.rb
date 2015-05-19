if swift.module_root && md = swift.slug.match( /show\/(.*)/ )
  swift.slug = md[1]
  swift.path_pages << Page.new
  throw :output, element( 'CatNode', @args, @opts )
end

@nodes = CatNode.all :cat_card_id => @card_ids
@group ||= @root_group
@nodes = @nodes.published.filter_by(@group) if @group

@per_page = @opts[:per_page] || 10

order = []
if params[:sort]
  if cache_field = @card.sort_cache[params[:sort]]
    order.unshift(params[:sort].to_sym)
  elsif cache_field = @card.sort_cache[params[:sort].sub('.desc','')]
    order.unshift(params[:sort].sub('.desc','').to_sym.desc)
  end
end

order = [ :sort2.desc, :sort1, :id ] if order.empty?

@pages_count = (@nodes.count - 1) / @per_page + 1
@current_page = params[:page] ? params[:page].to_i : 1
@nodes = @nodes.all(:limit => @per_page, :offset => (@current_page - 1) * @per_page, :order => order)
