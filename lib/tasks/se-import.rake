#coding:utf-8
require 'awesome_print'

class Legacy
  DATABASE = 'swift_purga_old'
  HTTPHOST_OLD = %r{http://www.malayapurga.ru/files/|http://malayapurga.ru/files/}
  HTTPHOST = 'http://archive.malayapurga.ru/'

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

  def self.markdown_archived_file(id)
    record = select("SELECT * FROM files_10000 WHERE id=#{id}").first
    if record
      "[#{Legacy.cleanup_uub(record[:name])}](#{HTTPHOST}files/#{id}.#{record[:ext]})"
    else
      "[missing file #{id}]"
    end
  end

  def self.unlegacify( str, options={} )
    str.gsub( /\&\[LEGACY ;(.*?)\&\];/, '\[\1\]' )
       .gsub /\[LEGACY\s+([^\]]+)\]/ do |tag|
         mm = $1
         case 
         when md = mm.match(/^file\s+([^\]]+)$/)
           if options[:archive_files]
             markdown_archived_file(md[1])
           else
             "[file #{md[1]}]"
           end
         when md = mm.match(/^table\s+([^\]]+)$/)
           "[block #{md[1]}]"
         when md = mm.match(/^b$|^\/b$/)
           "**"
         when md = mm.match(/^i$|^\/i$/)
           "*"
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
         when md = mm.match(/^up$/)
           "[sup]"
         when md = mm.match(/^\/up$/)
           "[/sup]"
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

  def self.render_table(str)
    return '' if str.blank?
    table = ''
    table << '<table><tbody>'
    str.each_line do |line|
      next if line.blank?
      @header = line.match(/\[.*?:\s*h\s*\]/)
      table << '<tr>'
        @newline = true
        line.split(/\[[^:\]]*:[^\]]*\]/).each do |cell|
          if @newline
            @newline = false
            next
          end
          table << (@header ? '<th>' : '<td>')
          table << cell
          table << (@header ? '</th>' : '</td>')
        end
      table << '</tr>'
    end
    table << '</tbody></table>'
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
    o.title = Legacy.cleanup_uub o.title
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
  main_rubric = NewsRubric.first
  news.each do |nw|
    o = NewsArticle.new
    #o.news_rubric = rubrics[nw.tape]
    o.news_rubric_id = main_rubric.id
    o.title = Legacy.cleanup_uub nw.name.to_s.strip
    o.info = Legacy.cleanup_uub nw.descr.to_s.strip
    o.text = Legacy.cleanup_uub nw.content.to_s.strip
    o.date = Time.at(nw.time_real).to_datetime
    o.save
    o.publish!
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

def se_import_tables
  Block.all(:slug => /^legacy_table/).destroy!
  tables = Legacy.select("SELECT * FROM tables_10000")
  tables.each do |table|
    begin
      o = Block.new
      o.id = table.id
      o.type = 2 #table
      o.title = Legacy.cleanup_uub(table.name.to_s.strip)
      o.slug = "legacy_table-#{table.id}"
      o.text = Legacy.render_table(table.content)
      o.text = Legacy.cleanup_uub(o.text)
      o.save || p(o.errors)
    rescue
      raise
    else
      #p o
    end
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
      #p o
      #p o.file.path
    end
  end
  pbar.finish
end

def se_retag(model, options={})
  send :"se_retag_#{model}", options
end

def se_retag_pages(options={})
  pages = Page.all :text.like => '%LEGACY%'
  pages.each do |page|
    page.text = Legacy.unlegacify(page.text, options)
    page.text = page.text.gsub(Legacy::HTTPHOST_OLD, File.join(Legacy::HTTPHOST,'files/')) if options[:archive_files]
    page.save
  end
end

def se_retag_news(options={})
  news = NewsArticle.all # :text.like => '%LEGACY%'
  pbar = ProgressBar.create :title => "news", :total => news.count
  news.each do |article|
    article.title = article.title.strip
    article.info = Legacy.unlegacify(article.info.strip, options)
    article.text = Legacy.unlegacify(article.text.strip, options)
    article.save
    pbar.increment
  end
  pbar.finish
end

def se_retag_tables(options={})
  tables = Block.all(:slug => /^legacy_table/)
  tables.each do |table|
    table.text = Legacy.unlegacify(table.text)
    puts table.text
    puts table.title
    table.save
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
      puts "USAGE: rake se:import['pages news files collections tables']\n"
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

    options = { :archive_files => true }

    if models = args[:args]
      models.split(/\s+/).each{ |model| se_retag(model, options) }
    else
      puts "USAGE: rake se:retag['pages news tables']\n"
      puts "   OR  rake se:retag['news']\n"
      puts "  etc.\n"
    end
  end

  desc 'write page positions'
  task :reposition => :environment do
    structures = Legacy.select("SELECT * FROM structure_10000")
    pages = Legacy.select("SELECT * FROM pages_10000")
    structures.each do |struct|
      struct_path = struct[:hru]
      pointer = struct
      while pointer[:root].to_i > 0
        parent = structures.select{ |s| s[:id] == pointer[:root] }.first
        struct_path = File.join(parent[:hru], struct_path)
        pointer = parent
      end
      page = Page.first( :path => '/'+struct_path )
      if page
        page.position = struct[:inposition].to_i*10
        page.save
      else
        ap "NO #{struct_path}"
      end
    end
  end
end
