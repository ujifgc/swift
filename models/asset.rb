class Asset
  include DataMapper::Resource

  property :id, Serial

  property :title, String

  nozzle! :file, AssetAdapter
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

  def info
    "#{title} (#{file.content_type}, #{file.size.as_size})"
  end
end
