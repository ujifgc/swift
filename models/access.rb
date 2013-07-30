class Access
  include DataMapper::Resource

  property :id, Serial

  #relations
  belongs_to :account, :required => true
  property :object_id, Integer, :required => true
  property :object_type, String, :required => true
  property :deny, Boolean, :required => true, :default => false
end
