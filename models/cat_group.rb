#coding:utf-8
class CatGroup
  include DataMapper::Resource

  property :id,       Serial

  property :title,    String, :required => true
  property :text,     Text

  sluggable!
  timestamps!
  userstamps!
  publishable!
  bondable!
  amorphous!
  recursive!
  bondable!

  # relations
  belongs_to :cat_card, :required => true

  # hookers

  # instance helpers
  
end