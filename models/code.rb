class Code
  include DataMapper::Resource

  property :id,        Serial
  property :title,     String
  property :text,      Text
  property :html,      Text, :lazy => false
  property :is_single, Boolean, :default => false

  sluggable!
  
end
