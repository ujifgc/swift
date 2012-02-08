#coding:utf-8
class Image
  include DataMapper::Resource

  property :id, Serial

  property :title, String, :required => true
  #property :file,  String, :length => 511, :required => true
  mount_uploader :file, ImageUploader

  timestamps!
  userstamps!

  #relations
  belongs_to :folder, :required => false

  #hookers
  before :valid? do
    self.title = 'image'  if self.title.blank?
  end

  before :save do |o|
    o.folder_id = 1  unless o.folder_id
  end

end
