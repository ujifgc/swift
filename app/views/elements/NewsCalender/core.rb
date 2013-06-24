@news_months = []
@news_years = []
@monthNames = I18n.t("date.month_names_nominative")

new_article = NewsArticle.by_slug swift.slug.match( /show\/(.*)/ )[1]  rescue nil
@new_year, @new_month = if new_article
  [new_article.date.year, new_article.date.month]
else
  [params[:year], params[:month]]
end

filter = {}
filter[:order] = :date.asc

@target = @opts[:root] || '/news'
active_rubrics = Bond.children_for(@page, 'NewsRubric')
if active_rubrics.empty? && swift.slug.present? && !swift.slug.match( /show\/(.*)/ )
  rubric = NewsRubric.by_slug(swift.slug)  or not_found
  active_rubrics << rubric
  @target = @swift[:uri]  if @page.is_module
end
filter[:news_rubric_id] = active_rubrics.map(&:id)  if active_rubrics.any? 

firstDate = NewsArticle.published.first(filter).date  rescue Date.today
lastDate = NewsArticle.published.last(filter).date  rescue Date.today
@news_years = firstDate.year..lastDate.year
@news_months = case
when firstDate.year == Date.today.year
  firstDate.mon..lastDate.mon
when @new_year.to_i == firstDate.year
  firstDate.mon..12
when @new_year.to_i == Date.today.year || !@new_year
  1..lastDate.mon
else
  1..12
end
