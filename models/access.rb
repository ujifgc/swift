class Access
  include DataMapper::Resource

  property :id, Serial

  #relations
  belongs_to :account, :required => true
  property :object_id, Integer, :required => true
  property :object_type, String, :required => true
  property :deny, Boolean, :required => true, :default => false

  def self.allowed?(object, account)
    accesses = all(:object_id => object.id, :object_type => object.class.name)
    allowed, denied = accesses.partition{ |access| !access.deny } #!!! TODO denied logic
    allowed.any?{ |access| account.allowed?(access.account) }
  end

  def self.allow!(object, account, deny=false)
    create(:object_id => object.id, :object_type => object.class.name, :account_id => account.id, :deny => deny)
  end

  def self.deny!(object, account)
    grant(object, account, false)
  end    
end
