def map_tree( from, level, prefix )
  pages = Page.published.all( :parent => from, :order => [:position, :path])
  len = pages.length
  k = 1
  tree = []
  
  pages.each do |page|
    ensued = swift.path_ids.include? page.id
    master = level == 0

    leaf = {}
    leaf[:title] = page.title
    leaf[:href] = page.path

    leaf[:class] = master ? 'master' : 'slave'
    leaf[:class] += ' active'  if ensued

    child = []
    if ensued || @opts[:expand]
      child = map_tree( page, level + 1, prefix + '/' + page.slug )
    end

    if child
      leaf[:class] += ' open'
      leaf[:child] = child
    else
      leaf[:class] += ' leaf'  if ensued && !master
    end

    leaf[:class] += ' first'  if k == 1
    leaf[:class] += ' last'   if k == len

    k += 1
    tree << leaf
  end

  tree
end

root_page = case @opts[:root]
when String
  Page.published.first(:path => @opts[:root])
when Fixnum
  Page.get(@opts[:root])
else
  @opts[:root]
end

root = root_page || Page.published.first(:parent_id => nil)
@tree = map_tree( root, 0, '' )
