@swift[:module_path_ids] = []
filter = {}
if @rubric
  filter[:news_rubric_id] = @rubric.id
elsif @active_rubrics.any?
  filter[:news_rubric_id] = @active_rubrics.map(&:id)
end
if params[:year]
  filter[:date] = Date.new(params[:year].to_i)..Date.new(params[:year].to_i,12,-1)
end
if params[:month]
  date_a = Date.new(params[:year].to_i,params[:month].to_i,1)
  filter[:date] = date_a..(date_a>>1)
end
@articles_count = NewsArticle.published.count(filter)

@per_page = @opts[:per_page] || 10

@pages_count = (@articles_count - 1) / @per_page + 1
@current_page = params[:page] ? params[:page].to_i : 1
filter.merge! :limit => @per_page, :offset => (@current_page - 1) * @per_page, :order => [ :date.desc, :id.desc ]

@articles = NewsArticle.published.all(filter)
