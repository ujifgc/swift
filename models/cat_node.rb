class CatNode
  include DataMapper::Resource

  property :id,       Serial

  property :title,    String, :required => true
  property :text,     Text

  sluggable!
  timestamps!
  userstamps!
  publishable!
  bondable!
  amorphous!

  # relations
  belongs_to :cat_card, :required => true

  # hookers

  # instance helpers

end
