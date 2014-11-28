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
      :file => { :code => 'link_to o.file.size.as_size + " #{File.extname o.file.url}", o.file.url?, :rel => "box-image"', :body_class => 'nowrap' }
    }
  )

  #relations
  belongs_to :folder, :required => true

  #hookers

  def info
    "#{title} (#{file.content_type}, #{file.size.as_size})"
  end
end
