@article = NewsArticle.by_slug swift.slug
not_found  unless @article
@article.text = @article.info  if @article.text.blank?
swift.path_pages[-1] = Page.new :title => @article.title
swift.resource = @article

@board = @article.dissertation.board
