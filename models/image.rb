class Image
  include DataMapper::Resource

  property :id, Serial

  property :title, String

  nozzle! :file, ImageAdapter
  timestamps!
  userstamps!
  loggable!
  bondable!
  datatables!( :id, :title, :folder, :file,
    :format => {
      :folder => { :code => 'o.folder && o.folder.title' },
      :file => { :code => 'link_to o.file.size.as_size + " #{File.extname o.file.url}", o.file.url?, :rel => "box-image"' }
    }
  )

  #relations
  property :folder_id, Integer, :default => 1
  belongs_to :folder, :required => false

  #hookers
  before :save do |o|
    o.folder_id = 1  unless o.folder_id
  end

  def info
    "#{title} (#{file.content_type}, #{file.size.as_size})"
  end
end
