#coding:utf-8
class Layout
  include DataMapper::Resource

  property :title, String

  # plugins
  sluggable! :key => true
  timestamps!
  userstamps!

  # relations
  has n, :pages
  
end
