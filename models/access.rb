#coding:utf-8
class Access
  include DataMapper::Resource

  property :read_only, Boolean, :default => false

  #relations
  belongs_to :account, :required => true, :key => true
  property :accessible_id, Integer, :required => true, :key => true
  property :accessible_type, String, :key => true

  # hookers

  # instance helpers

end
