#coding:utf-8
require 'awesome_print'

class Legacy
  DATABASE = 'swift_purga_old'

  def self.initialize
    return  if @legacy
    settings = YAML.load_file( Padrino.root('config/database.yml') )[RACK_ENV]
    settings['database'] = DATABASE
    DataMapper.setup :legacy, settings
    @legacy = repository(:legacy).adapter
  end

  def self.select( q )
    initialize
    @legacy.select(q)
  end

  def self.unlegacify( str )
    str.gsub( /\&\[LEGACY ;(.*?)\&\];/, '\[\1\]' )
       .gsub /\[LEGACY\s+([^\]]+)\]/ do |tag|
         mm = $1
         case 
         when md = mm.match(/^file\s+([^\]]+)$/)
           "[file #{md[1]}]"
         when md = mm.match(/^table\s+([^\]]+)$/)
           "[block #{md[1]}]"
         when md = mm.match(/^b$|^\/b$/)
           "**"
         when md = mm.match(/^hr$/)
           "\n\n----------\n\n"
         when md = mm.match(/^tab(\s+\d+)?$/)
           " "
         when md = mm.match(/^i$|^\/i$/)
           "*"
         when md = mm.match(/^image\s+(\d+)\s*([^\]]*)?$/)
           '[image' + (md[2] ? ".#{md[2]}" : "") + " #{md[1]}]"
         when md = mm.match(/^p right$|^p center$/)
           "\n"
         when md = mm.match(/^h2$/)
           "\n\n## "
         when md = mm.match(/^\/h2$/)
           "\n\n"
         when md = mm.match(/^h3$/)
           "\n\n### "
         when md = mm.match(/^\/h3$/)
           "\n\n"
         when md = mm.match(/^elink\s+(.*)$/)
           @url = md[1]
           "["
         when md = mm.match(/^\/elink$/)
           "](#{@url})"
         else 
           ap [tag, mm]
           tag
         end
       end
       .gsub(/\*\*\s*([^*]*?)\s*\*\*/,'**\1**')
  end

  def self.cleanup_uub( str )
    str.gsub(/\[(.*?)\s*\]/) do |tag|
      case
      when tag == '[p]'
        "\n"
      when tag == '[/p]'
        "\n\n"
      when tag == '[br]'
        "  \n"
      when tag == '[/br]'
        ""
      when tag.match(/\[\/?list-[o1]\]/)
        ""
      when md = tag.match( /\[nlink\s+(.*)\]/ )
        @url = md[1]
        "["
      when tag == '[/nlink]'
        "](#{@url})"
      when tag == '[li]'
        "\n * "
      else
        "#{tag}".gsub('[', '[LEGACY ')
      end
    end.gsub(/\A\n/, "")
       .gsub(/\n\n+/, "\n\n")
       .gsub(/ \n/, "\n")
       .gsub(/   +/, "  ")
       .gsub(/\&\#(\d+)\;/) { |u| [$1.to_i].pack('U') }
       .gsub('&nbsp;', " ")
       .gsub(/^([^\*]{3})(.*)\n \* (.*)$/, "\\1\\2\n\n * \\3")
       .gsub('&laquo;', '«')
       .gsub('&raquo;', '»')
       .gsub('&quot;', '"')
  end
end

def se_import( table )
  method = :"se_import_#{table}"
  send method
end

def se_import_pages
  legacy_root = Page.first_or_create( { :slug => 'legacy_tree' }, { :title => 'Legacy Tree', :slug => 'legacy_tree', :parent => Page.first(:path => '/') } )
  Page.all( :path.like => '/legacy_tree/%' ).destroy!
  structures = Legacy.select("SELECT * FROM structure_10000")
  pages = Legacy.select("SELECT * FROM pages_10000")
  new_pages = []
  pages.each do |page|
    structure = structures.select{ |s| s.page == page.id }.first  or next
    structure.id > 0  or next
    o = Page.new
    o.text = Legacy.cleanup_uub( page.content || '' )
    o.title = structure.alias.to_s.strip
    o.title = page.name.strip  if o.title.blank?
    o.title = page.id  if o.title.blank?
    o.slug = structure.hru
    o.parent_id = legacy_root.id
    o.save
    new_pages << [o, page, structure]
  end
  new_pages.each do |ary|
    o, p, s = ary
    rt = new_pages.select{ |np| np[2].id == s.root }.first  or next
    o.parent = rt[0]
    o.save
  end
end

def se_import_news
  #rubric = NewsRubric.first_or_create( { :slug => 'legacy_rubric' }, { :title => 'Legacy rubric', :slug => 'legacy_rubric' } )
  NewsRubric.all( :slug.like => 'legacy_%' ).each do |rub|
    rub.news_articles.destroy!
    rub.destroy!
  end
  tapes = Legacy.select("SELECT * FROM mntapes_10000")
  rubrics = {}
  tapes.each do |tape|
    rubrics[tape.id] = NewsRubric.create( :title => tape.name, :slug => "legacy_#{tape.code}" )
  end
  ap rubrics
  news = Legacy.select "SELECT * FROM mnnews_10000 WHERE status='y'"
  pbar = ProgressBar.create :title => "news", :total => news.count
  news.each do |nw|
    o = NewsArticle.new
    o.news_rubric = rubrics[nw.tape]
    o.title = Legacy.cleanup_uub nw.name.to_s.strip
    o.info = Legacy.cleanup_uub nw.descr.to_s.strip
    o.text = Legacy.cleanup_uub nw.content.to_s.strip
    o.date = Time.at(nw.time_real).to_datetime
    o.save
    pbar.increment
  end
  pbar.finish
end

def se_import_files
  files = Legacy.select("SELECT * FROM files_10000")
  folder = Folder.first_or_create( :title => "legacy-files" )
  folder.assets.destroy
  pbar = ProgressBar.create :title => "files", :total => files.count
  files.each do |file|
    begin
      o = Asset.new
      o.id = file.id
      o.title = Legacy.cleanup_uub file.name.to_s.strip
      o.folder = folder
      o.file = File.open("tmp/malayapurga.ru/html/files/#{file.id}.#{file.ext}")
      o.save
      pbar.increment
    rescue
      p 'error no file'
    else
      p o
    end
    pbar.finish
  end
end

def se_import_collections
  collections = Legacy.select("SELECT * FROM collections_10000")
  folder = Folder.first_or_create( :title => "legacy-images" )
  folder.images.destroy
  pbar = ProgressBar.create :title => "collections", :total => collections.count
  collections.each do |collection|
    begin
      o = Image.new
      o.id = collection.id
      o.title = Legacy.cleanup_uub collection.name.to_s.strip
      o.folder = folder
      o.file = File.open(Dir.glob("tmp/malayapurga.ru/html/img/#{collection.id}/*").sort.last)
      o.save
      pbar.increment
    rescue
      p 'error no image file'
    else
      p o
      p o.file.path
    end
  end
  pbar.finish
end

def se_retag( model )
  method = :"se_retag_#{model}"
  send method
end

def se_retag_pages
  pages = Page.all :text.like => '%LEGACY%'
  pages.each do |page|
    page.text = Legacy.unlegacify(page.text)
    page.save
  end
end

def se_retag_news
  news = NewsArticle.all :text.like => '%LEGACY%'
  news.each do |article|
    article.text = Legacy.unlegacify(article.text)
    article.save
  end
end

namespace :se do
  desc "load tables from old engine"
  task :import, :args do |t, args|
    require File.expand_path('config/boot.rb', Rake.application.original_dir)

    Padrino.mounted_apps.each do |app|
      app.app_obj.setup_application!
    end

    #'pages news files collections'
    if tables = args[:args]
      tables.split(/\s+/).each{ |table| se_import(table) }
    else
      puts "USAGE: rake se:import['pages news files collections']\n"
      puts "   OR  rake se:import['news']\n"
      puts "  etc.\n"
    end
  end

  desc "replace legacy tags"
  task :retag, :args do  |t, args|
    require File.expand_path('config/boot.rb', Rake.application.original_dir)

    Padrino.mounted_apps.each do |app|
      app.app_obj.setup_application!
    end

    if models = args[:args]
      models.split(/\s+/).each{ |model| se_retag(model) }
    else
      puts "USAGE: rake se:retag['pages news']\n"
      puts "   OR  rake se:retag['news']\n"
      puts "  etc.\n"
    end
  end
end
