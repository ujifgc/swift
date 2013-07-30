class Folder
  include DataMapper::Resource

  property :id, Serial
    
  property :title, String, :required => true
  property :text,  Text
  property :is_private,  Boolean, :default => false

  timestamps!
  userstamps!
  loggable!
  sluggable!
  bondable!

  # relations
  belongs_to :account, :required => false
  has n, :images
  has n, :assets

  # class helper
  def self.with( type )
    type = type.to_s.pluralize
    return []  unless ['images', 'assets'].include? type
    Folder.all(:conditions => [ "0 < (SELECT count(id) FROM `#{type}` WHERE folder_id=`folders`.id)" ])
  end
end
