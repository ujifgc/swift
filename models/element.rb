class Element
  include DataMapper::Resource

  property :id, String, :length => 63, :key => true
  property :title, String
  property :text, Text

  # hookers
  before :valid? do
    self.id = title  if id.blank?
  end
end
