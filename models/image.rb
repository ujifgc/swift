#coding:utf-8
class Image
  include DataMapper::Resource

  property :id, Serial

  property :title, String
  mount_uploader :file, ImageUploader

  timestamps!
  userstamps!

  #relations
  belongs_to :folder, :required => false

  #hookers
  before :save do |o|
    o.folder_id = 1  unless o.folder_id
  end

end
