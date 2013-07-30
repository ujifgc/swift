class CatGroup
  include DataMapper::Resource

  property :id,       Serial

  property :title,    String, :required => true
  property :text,     Text

  sluggable!
  timestamps!
  userstamps!
  loggable!
  publishable!
  bondable!
  amorphous!
  recursive!
  bondable!

  # relations
  belongs_to :cat_card, :required => true
end
