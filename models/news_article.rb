#coding:utf-8
class NewsArticle
  include DataMapper::Resource

  property :id,       Serial

  property :title,    String
  property :text,     Text

  sluggable!
  timestamps!
  userstamps!
  publishable!

  # relations
  property :news_rubric_id, Integer, :default => 1
  belongs_to :news_rubric, :required => true

  # hookers

  # instance helpers

end
