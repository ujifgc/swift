class Element
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial

  sluggable!
  
end
