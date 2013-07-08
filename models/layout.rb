#coding:utf-8
class Layout
  include DataMapper::Resource

  property :id, String, :length => 20, :key => true
  property :title, String

  # plugins
  timestamps!
  userstamps!
  loggable!

  # relations
  has n, :pages, :child_key => :layout_id
  
  # hookers
  before :valid? do
    self.id = self.title  if self.id.blank?
  end

  after :create do
    FileUtils.touch "#{Swift::Application.views}/layouts/#{id}.slim"
  end

end
