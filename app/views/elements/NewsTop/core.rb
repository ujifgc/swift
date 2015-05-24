include = @opts[:include] || @opts[:rubrics]

filter = {}
filter['news_rubric.slug'] = inc.to_s.split /\W+/                  if include
filter['news_rubric.slug.not'] = @opts[:exclude].to_s.split /\W+/  if @opts[:exclude]

order = [ Sequel.desc(:date), Sequel.desc(:id) ]

limit = @opts[:limit].to_i if @opts[:limit]
limit ||= 5
offset = @opts[:offset].to_i if @opts[:offset]

@articles = NewsArticles.published.where(filter).order(*order).offset(offset).limit(limit)
