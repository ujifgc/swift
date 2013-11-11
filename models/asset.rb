class Asset
  include DataMapper::Resource

  property :id, Serial

  property :title, String

  nozzle! :file, AssetAdapter
  timestamps!
  userstamps!
  loggable!
  datatables!( :id, :title, :folder, :file,
    :format => {
      :folder => { :code => 'o.folder && o.folder.title' },
      :file => { :code => 'link_to o.file.size.as_size + " / #{File.extname o.file.url}", o.file.url?  rescue "error"' }
    }
  )

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
