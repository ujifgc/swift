class NewsRubric
  include DataMapper::Resource

  property :id,       Serial

  property :title,    String, :required => true
  property :text,     Text

  sluggable!
  timestamps!
  userstamps!
  loggable!
  bondable!

  # relations
  has n, :news_articles
  has n, :news_events

  # hookers

  # instance helpers

  # class helpers
  def self.with( type )
    type = type.to_s.pluralize
    return []  unless ['news_articles', 'news_events'].include? type
    NewsRubric.all(:conditions => [ "0 < (SELECT count(id) FROM `#{type}` WHERE news_rubric_id=`news_rubrics`.id)" ])
  end
end
