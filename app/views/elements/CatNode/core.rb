@node = CatNode.by_slug @swift[:slug]
not_found  unless @node
@swift[:path_pages][-1] = Page.new :title => @node.title
@swift[:resource] = @node
