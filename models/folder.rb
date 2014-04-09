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

  def self.for_card(card)
    return unless card
    return card.folder if card.folder
    first_attributes = { :slug => "cat-card-#{card.slug}" }
    create_attributes = { :title => "Загрузки карточки #{card.title}" }
    Folder.first_or_create(first_attributes, first_attributes.merge(create_attributes))
  end
end
