#coding:utf-8
class Page
  include DataMapper::Resource

  property :id,        Serial

  property :title,     String
  property :text,      Text, :lazy => false
  property :path,      String, :length => 2000, :index => true
  property :position,  Integer
  property :is_module, Boolean, :default => false
  property :params,    String, :length => 2000

  sluggable! :unique_index => false
  publishable!
  timestamps!
  userstamps!
  bondable!
  loggable!

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
    if self.position.blank?
      max = Page.all( :parent => self.parent ).published.max :position
      self.position = max.to_i + 5
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

  def reposition!( dir )
    opos = self.position
    sibling = case dir.downcase.to_sym
    when :up
      Page.first :position.lte => opos, :id.not => self.id, :parent_id => self.parent_id, :order => [:position.desc]
    when :down
      Page.first :position.gte => opos, :id.not => self.id, :parent_id => self.parent_id, :order => [:position]
    end
    if sibling
      self.position = sibling.position
      self.save
      sibling.position = opos
      sibling.save
    end
  end

end
