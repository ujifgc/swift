#coding:utf-8
class Block
  include DataMapper::Resource

  property :id,       Serial

  property :title,    String
  property :text,     Text

  property :type,     Integer, :default => 0
  Types = {
    0 => :text,
    1 => :html,
    2 => :table
  }

  sluggable!
  timestamps!
  userstamps!

  #relations
  belongs_to :folder, :required => false

  # hookers

  # instance helpers
  def html?
    self.type > 0
  end

end
