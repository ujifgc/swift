class NewsArticle
  include DataMapper::Resource

  property :id,       Serial

  property :title,    String
  property :info,     Text
  property :text,     Text

  sluggable!
  timestamps!
  userstamps!
  loggable!
  publishable!
  bondable!
  dateable!
  metable!

  # relations
  property :news_rubric_id, Integer, :default => 1
  belongs_to :news_rubric, :required => true

  # validations
  validates_presence_of      :title

  # hookers

  # instance helpers
end
