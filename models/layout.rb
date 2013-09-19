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
    self.id = title  if id.blank?
  end

  after :destroy do
    FileUtils.rm_f "#{Swift::Application.views}/layouts/#{id}.slim"
  end
end
