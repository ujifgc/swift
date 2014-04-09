filter = {}
filter[:limit] = @opts[:limit].to_i if @opts[:limit]
filter[:limit] ||= 5
filter[:order] = [ :updated_at.desc, :id.desc ]
filter[:is_system] = false
@fresh_pages = Page.published.all(filter)
