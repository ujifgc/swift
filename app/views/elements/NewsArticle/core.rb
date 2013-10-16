@new = NewsArticle.by_slug swift.slug
not_found  unless @new
@new.text = @new.info  if @new.text.blank?
swift.path_pages[-1] = Page.new :title => @new.title
swift.resource = @new
