#coding:utf-8
class Image
  include DataMapper::Resource

  property :id, Serial

  property :title, String

  nozzle! :file, ImageAdapter
  uploadable!
  timestamps!
  userstamps!
  loggable!
  bondable!

  #relations
  property :folder_id, Integer, :default => 1
  belongs_to :folder, :required => false

  #hookers
  before :save do |o|
    o.folder_id = 1  unless o.folder_id
  end

end
