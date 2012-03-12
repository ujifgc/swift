#coding:utf-8
class Folder
  include DataMapper::Resource

  property :id, Serial
    
  property :title, String, :required => true

  timestamps!
  userstamps!
  sluggable!

  #relations
  belongs_to :account, :required => false
  has n, :images
  has n, :assets

  # class helpert
  def self.with( type )
    type = type.to_s.pluralize
    return []  unless ['images', 'assets'].include? type
    Folder.all(:conditions => [ "0 < (SELECT count(id) FROM `#{type}` WHERE folder_id=`folders`.id)" ])
  end

end
