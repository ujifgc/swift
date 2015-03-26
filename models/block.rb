class Block
  include DataMapper::Resource

  property :id,       Serial

  property :title,    String
  property :text,     Text

  property :type,     Integer, :default => 0
  Types = {
    0 => :text,
    1 => :html,
    2 => :table,
  }

  sluggable!
  timestamps!
  userstamps!
  loggable!
  datatables!( :id, :title, :type, :slug,
    :format => { :type => { :code => 'o.get_type' } }
  )
  multilingual! :text, :optional => :text

  # validations
  validates_presence_of :title

  # relations
  belongs_to :folder, :required => false

  # hookers

  # instance helpers
  def html?
    type == 1
  end

  def table?
    type == 2
  end

  def self.get_type(type)
    I18n.t "models.object.attributes.type_#{Types[type]}"
  end

  def get_type
    self.class.get_type(type)
  end
end
