#coding:utf-8
class Page
  include DataMapper::Resource

  property :id,        Serial

  property :title,     String
  property :text,      Text, :lazy => false
  property :path,      String, :length => 2000, :index => true
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
  positionable!

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

  def rebuild_path
    parent ? parent.parent ? parent.path + '/' + slug : '/' + slug : '/'
  end

  def change_path!( parent_path )
    self.path = parent_path + '/' + slug
    save!
    children.each{ |ch| ch.change_path! path }
  end

  def last_update
    case
    when is_system && slug == 'news'
      NewsArticle.last(:order => :updated_at).updated_at
    else
      updated_at
    end
  end
end
