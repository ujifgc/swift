#coding:utf-8
class Block
  include DataMapper::Resource

  property :id,       Serial

  property :title,    String
  property :text,     Text

  sluggable!
  publishable!
  timestamps!
  userstamps!

  # hookers

  # instance helpers

end
