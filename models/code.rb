class Code
  include DataMapper::Resource

  property :id,          Serial
  property :title,       String, :required => true
  property :icon,        String
  property :placeholder, String
  property :text,        Text
  property :html,        Text, :lazy => false
  property :is_single,   Boolean, :default => false
  property :is_system,   Boolean, :default => false

  sluggable!
end
