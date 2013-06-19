inc = @opts[:include] || @opts[:rubrics]
filter = {}
filter['news_rubric.slug'] = inc.to_s.split /\W+/                  if inc
filter['news_rubric.slug.not'] = @opts[:exclude].to_s.split /\W+/  if @opts[:exclude]
filter[:offset] = @opts[:offset].to_i                              if @opts[:offset]
filter[:limit] = @opts[:limit].to_i                                if @opts[:limit]
filter[:limit] ||= 5
filter[:order] = [ :date.desc, :id.desc ]
@news = NewsArticle.published.all( filter )
