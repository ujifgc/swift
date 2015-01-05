class Fragment
  include DataMapper::Resource

  property :id, String, :length => 20, :key => true
  property :title, String
  property :is_fragment, Boolean, :default => false
  property :is_module, Boolean, :default => false

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

  after :destroy do
    FileUtils.rm_f "#{Swift::Application.views}/fragments/#{id}.slim"
  end

  def usage
    count = pages.count
    count > 0 ? count : nil
  end

  def self.fragments
    all :is_fragment => true
  end

  def self.basic
    all :is_fragment => false
  end
end
