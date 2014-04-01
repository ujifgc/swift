swift.module_path_ids = []
@rubrics = NewsRubric.all
@active_rubrics = []

if md = swift.slug.match( /show\/(.*)/ )
  swift.slug = md[1]
  swift.path_pages << Page.new
  throw :output, element( 'NewsArticle', @args, @opts )
end

if swift.slug == ''
  @active_rubrics = Bond.children_for(@page, 'NewsRubric')
  core = element( 'NewsRubrics', @args, @opts )
  core += element( 'NewsPager', @args, @opts )
  throw :output, core
end

if md = swift.slug.match( /.+/ )
  steps = swift.slug.split( '/' )
  steps.each do |step|
    rubric = @rubrics.by_slug(step)
    not_found  unless rubric
    not_found  if swift.module_path_ids.last && rubric.parent_id != swift.module_path_ids.last
    swift.module_path_ids << rubric.id
    @active_rubrics << rubric
    swift.path_pages << Page.new(:title => rubric.title, :path => swift.url)
  end

  core = element( 'NewsRubrics', @args, @opts )
  core += element( 'NewsPager', @args, @opts )
  throw :output, core
end
