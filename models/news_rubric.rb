#coding:utf-8
class NewsRubric
  include DataMapper::Resource

  property :id,       Serial

  property :title,    String
  property :text,     Text

  sluggable!
  timestamps!
  userstamps!

  # relations
  has n, :news_articles

  # hookers

  # instance helpers

end
