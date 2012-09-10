@swift[:module_path_ids] = []
# FIXME maybe use `children_for`?
bonds = Bond.bonds_for @page, 'CatCard'
@card_ids = bonds.map(&:child).map(&:id)
@groups = CatGroup.all :cat_card_id => @card_ids

if md = @swift[:slug].match( /show\/(.*)/ )
  @swift[:skip_view]['Cat'] = true
  @swift[:slug] = md[1]
  @swift[:path_pages] << Page.new
  return element( 'CatNode', @args, @opts )
end

if md = @swift[:slug].match( /.*/ )
  steps = @swift[:slug].split( '/' )
  steps.each do |step|
    group = @groups.by_slug(step)
    not_found  unless group
    not_found  if @swift[:module_path_ids].last && group.parent_id != @swift[:module_path_ids].last
    @swift[:module_path_ids] << group.id
    @group = group
  end
  @swift[:skip_view]['Cat'] = true
  core = element( 'CatGroups', @args, @opts )
  core += element( 'CatNodes', @args, @opts )
  return core
end
