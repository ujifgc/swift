class Translation
  include DataMapper::Resource

  property :id,           Serial
  property :locale,       String, :length => 7
  property :object_model, String, :length => 31
  property :object_id,    Integer
  property :field,        String
  property :text,         Text,   :lazy => false
end
