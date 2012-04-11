#coding:utf-8
class Page
  include DataMapper::Resource

  property :id,        Serial

  property :title,     String
  property :text,      Text, :lazy => false
  property :path,      String, :length => 2000, :index => true
  property :position,  Integer
  property :is_module, Boolean, :default => false

  sluggable! :unique_index => false
  publishable!
  timestamps!
  userstamps!
  bondable!

  # relations
  has n, :children, 'Page', :child_key => :parent_id
  belongs_to :parent, 'Page', :required => false

  property :layout_id, String, :length => 20, :default => 'application'
  belongs_to :layout, :required => false

  property :fragment_id, String, :length => 20, :default => 'page'
  belongs_to :fragment, :required => false

  # validations
  validates_presence_of :title
  validates_uniqueness_of :path

  # hookers
  before :valid? do
    self.parent_id = nil  if self.id == self.parent_id
    if self.position == nil || self.position == ''
      max = Page.all( :parent => self.parent ).max :position
      self.position = max.to_i + 1
    end
  end

  before :save do
    self.path = self.parent ? self.parent.parent ? self.parent.path + '/' + self.slug : '/' + self.slug : '/'
  end

  # instance helpers
  def title_tree
    prepend = ''
    cp = self.parent_id
    while cp do
      cp = Page.get(cp).parent_id
      prepend += '· · '
    end
    "#{prepend} #{title} (#{slug})"
  end

  def root?
    self.path == '/'
  end


  validates_with_method :zip_code, :method => :in_the_right_location?

  def in_the_right_location?
    return [false, "You're in the wrong zip code"]
  end

end
