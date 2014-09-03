models = @opts[:models] || [Page, NewsArticle]
limit = @opts[:limit] || 5

@updated_objects = []
models.each do |model|
  @updated_objects += model.published.all( :order => :updated_at ).last(limit).to_a
end
@updated_objects = @updated_objects.sort_by{ |object| -object.updated_at.to_i }.first(limit)
