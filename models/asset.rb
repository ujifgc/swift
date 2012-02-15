#coding:utf-8
class Asset
  include DataMapper::Resource

  property :id, Serial

  property :title, String
  mount_uploader :file, AssetUploader

  timestamps!
  userstamps!

  #relations
  belongs_to :folder, :required => false

  #hookers
  before :save do |o|
    o.folder_id = 2  unless o.folder_id
  end

end
