#coding:utf-8
class Asset
  include DataMapper::Resource

  property :id, Serial

  property :title, String

  nozzle! :file, AssetAdapter
  uploadable!
  timestamps!
  userstamps!
  loggable!

  #relations
  property :folder_id, Integer, :default => 2
  belongs_to :folder, :required => false

  #hookers
  before :save do |o|
    o.folder_id = 2  unless o.folder_id
  end

end
