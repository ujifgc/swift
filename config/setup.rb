#coding:utf-8

# load yml to database [Code]
seeds = YAML::load File.open('config/setup.yml')
seeds.each do |model_name, elements|
  model = model_name.constantize
  elements.each do |slug, attributes|
    elem = model.first_or_new :slug => slug
    if elem.new?
      elem.attributes = attributes.merge( :slug => slug )
      elem.save  or p "error on #{model_name} #{slug}"
    else
      p "skipped existing #{model_name} #{slug}"
    end
  end  
end

# load elements do db
elements = YAML.load_file 'config/setup-elements.yml'
Dir.glob( Swift.root / 'views/elements/*' ) do |dir|
  slug = File.basename(dir)
  elem = Element.first_or_new :id => slug
  if elem.new?
    elem.title = elements['Element'][slug]['title']  rescue slug
    elem.save  or p "error on Element #{slug}"
  else
    p "skipped existing Element #{slug}"
  end
end

# load other objects !!! FIXME into the yml
k = 1
ACCOUNT_GROUPS.each do |g|
  pwd = SecureRandom.hex(4)
  a = Account.create :id => k, :email => "#{g}@localhost", :name => g, :surname => 'group', :password => pwd, :password_confirmation => pwd, :group => nil
  k += 1
end
account = Account.first

# pages

root  = Page.create :parent => nil,   :slug => '',        :title => 'Index', :text => 'index'
error = Page.create :parent => root,  :slug => 'error',   :title => 'Error', :text => 'Default error page', :is_published => false, :position => 901
admin = Page.create :parent => root,  :slug => 'admin',   :title => 'Admin panel', :position => 900

Page.create         :parent => error, :slug => '404',     :title => '404 Not Found',   :text => 'Sorry, page not found', :is_published => false, :position => 902
Page.create         :parent => error, :slug => '501',     :title => '501 Service Unavailable',   :text => 'Sorry, requested service is unavailable', :is_published => false, :position => 903

# folders
Folder.create :id => 1, :account => nil, :title => 'Layout graphics', :slug => 'images'
Folder.create :id => 2, :account => nil, :title => 'Common files', :slug => 'files'

# layouts
Layout.create :id => 'application', :title => 'Default app'
Layout.create :id => 'raw',         :title => 'Raw data'

# fragments
Fragment.create :title => 'Footer',       :id => 'footer', :is_fragment => true
Fragment.create :title => 'Header',       :id => 'header', :is_fragment => true
Fragment.create :title => 'Default page', :id => 'page',   :is_fragment => false
