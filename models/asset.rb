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

  before :update do
    original_folder = original_attributes.find{ |property, value| property.name == :folder_id }
    original_folder = Folder.get(original_folder.last) if original_folder.kind_of?(Array)
    if original_folder && !original_attributes.find{ |property, _| property.name == :file }
      @original_file_path = File.join(file.root(original_folder), file.relative_folder(original_folder), file.filename)
    end
  end

  after :save do
    if @original_file_path && @original_file_path != file.path
      begun = Time.now
      FileUtils.mv_try @original_file_path, file.path
      logger.devel :move, begun, "#{@original_file_path} => #{file.path}"
    end
  end

  def info
    "#{title} (#{mime})"
  end

  def mime
    "#{file.content_type}, #{file.size.as_size}"
  end
end
