#coding:utf-8
class Block
  include DataMapper::Resource

  property :id,       Serial

  property :title,    String
  property :text,     Text

  sluggable!
  timestamps!
  userstamps!

  #relations
  belongs_to :folder, :required => false

  # hookers

  # instance helpers

end
