#coding:utf-8
class Fragment
  include DataMapper::Resource

  property :title, String
  property :is_fragment, Boolean, :default => false

  # plugins
  sluggable! :key => true
  timestamps!
  userstamps!

  def self.fragments
    all :is_fragment => true
  end

end
