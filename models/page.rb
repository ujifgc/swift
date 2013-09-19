#coding:utf-8
class Page
  include DataMapper::Resource

  property :id,        Serial

  property :title,     String
  property :text,      Text, :lazy => false
  property :path,      String, :length => 2000, :index => true
  property :position,  Integer
  property :is_module, Boolean, :default => false
  property :is_system, Boolean, :default => false
  property :params,    String, :length => 2000

  sluggable! :unique_index => false
  publishable!
  timestamps!
  userstamps!
  loggable!
  bondable!
  metable!

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
    self.parent_id = nil  if id == parent_id
    if position.blank?
      max = Page.all( :parent => parent ).published.max :position
      self.position = max.to_i + 5
    else
      while duplicate = Page.first( :parent => parent, :position => position, :id.not => id )
        self.position += 5
      end
    end
  end

  before :save do
    old_path = path
    self.path = rebuild_path
    children.each{ |ch| ch.change_path!(path) }  if old_path != path
  end

  before :destroy do
    throw :halt  if is_system
  end

  def self.root
    first :parent_id => nil
  end

  # instance helpers
  def title_tree
    prepend = ''
    cp = parent_id
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
    opos = position
    sibling = case dir.downcase.to_sym
    when :up
      Page.first :position.lte => opos, :id.not => id, :parent_id => parent_id, :order => [:position.desc]
    when :down
      Page.first :position.gte => opos, :id.not => id, :parent_id => parent_id, :order => [:position]
    end
    if sibling
      if position == sibling.position
        Page.reposition_all!
      else
        self.position = sibling.position
        save!
        sibling.position = opos
        sibling.save!
      end
    end
  end

  def has_parent?( object )
    return false  if object.nil?
    oid = object.kind_of?( Numeric ) ? object : object.id
    return true  if oid == id
    has_parent = false
    page = self
    while page.parent_id
      has_parent ||= page.parent_id == oid
      page = page.parent
    end
    has_parent
  end

  def self.reposition_all!
    position = 0
    all( :order => [ :parent_id, :position, :id ] ).to_a.each do |page|
      position += 5
      page.position = position
      page.save!
    end
  end

  def rebuild_path
    parent ? parent.parent ? parent.path + '/' + slug : '/' + slug : '/'
  end

  def change_path!( parent_path )
    self.path = parent_path + '/' + slug
    save!
    children.each{ |ch| ch.change_path! path }
  end
end
