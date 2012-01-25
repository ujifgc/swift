#coding:utf-8
class Page
  include DataMapper::Resource

  property :id,       Serial

  property :title,    String
  property :text,     Text
  property :path,     String, :length => 2000
  property :layout,   String, :length => 63, :default => 'application'
  property :priority, Integer

  sluggable!
  publishable!
  timestamps!
  userstamps!

  # relations
  has n, :children, 'Page', :child_key => :parent_id
  belongs_to :parent, 'Page', :required => false

  # hookers
  before :valid? do
    self.parent_id = nil  if self.id == self.parent_id
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

end
