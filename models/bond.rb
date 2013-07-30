class Bond
  include DataMapper::Resource

  property :id, Serial

  property :created_at, DateTime
  property :updated_at, DateTime

  #model and id of first bonding object
  property :parent_model, String, :length => 31
  property :parent_id, Integer

  #model and id of second bonding object
  property :child_model, String, :length => 31
  property :child_id, Integer

  #1: parent - child
  #2: sibling - sibling
  property :relation, Integer, :default => 1

  #true for manually set relations, for example, quick links for a page, bound images for a gallery
  #false for automatically created bonds for caching purpose, such as prerendered tables or blocks
  property :manual, Boolean, :default => true
  #!!!FIXME add automatic detection of bonds


  ##instance methods 

  #get first object, resolving a model
  def parent
    o = Object.const_get(parent_model) rescue nil
    o && o.get(parent_id)
  end

  #get second object
  def child
    o = Object.const_get(child_model) rescue nil
    o && o.get(child_id)
  end

  ##class methods

  #get bound objects (of specified type [child_models]) for given object [parent]
  def self.bonds_for( parent, child_models = [] )
    filter = {
      :parent_model => parent.class.name,
      :parent_id    => parent.id,
      :manual       => true,
      :relation     => 1,
    }
    child_models = Array(child_models).map{|cm|cm.to_s.singularize.camelize}.compact
    filter[:child_model] = child_models  if child_models.any?
    all filter
  end

  #get child objects (of one specified type [child_model]) for given object [parent]
  def self.children_for( parent, child_model )
    bonds = bonds_for parent, [child_model]
    child_model.constantize.all :id => bonds.map(&:child).map(&:id)
  end

  def self.generate parent, child
    object = {
      :parent_model => parent.class.name,
      :parent_id    => parent.id,
      :child_model  => child.class.name,
      :child_id     => child.id,
      :manual       => true,
      :relation     => 1,
    }
    first_or_create object
  end

  def self.separate object
    parent = {
      :parent_model => object.class.name,
      :parent_id    => object.id,
      :manual       => true,
      :relation     => 1,
    }
    child = {
      :child_model  => object.class.name,
      :child_id     => object.id,
      :manual       => true,
      :relation     => 1,
    }
    all(parent).destroy
    all(child).destroy
  end
end
