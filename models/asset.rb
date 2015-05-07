class Asset
  include DataMapper::Resource

  property :id, Serial

  property :title, String, :length => 4095

  nozzle! :file, AssetAdapter
  timestamps!
  userstamps!
  loggable!
  datatables!( :id, :title, :folder, :file,
    :format => {
      :folder => { :code => 'o.folder && o.folder.title' },
      :file => { :code => 'link_to o.file.size.as_size + " / #{File.extname o.file.url}", o.file.url?  rescue "error"', :body_class => 'nowrap' }
    }
  )

  #relations
  belongs_to :folder, :required => true

  #hookers

  def info
    "#{title} (#{mime})"
  end

  def mime
    "#{file.content_type}, #{file.size.as_size}"
  end
end
