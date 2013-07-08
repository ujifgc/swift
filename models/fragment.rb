#coding:utf-8
class Fragment
  include DataMapper::Resource

  property :id, String, :length => 20, :key => true
  property :title, String
  property :is_fragment, Boolean, :default => false

  # plugins
  timestamps!
  userstamps!
  loggable!

  # relations
  has n, :pages, :child_key => :fragment_id

  # hookers
  before :valid? do
    self.id = title  if id.blank?
  end

  after :create do
    FileUtils.touch "#{Swift::Application.views}/fragments/_#{id}.slim"
  end

  def self.fragments
    all :is_fragment => true
  end

  def self.basic
    all :is_fragment => false
  end

end
