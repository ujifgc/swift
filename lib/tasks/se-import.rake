#coding:utf-8

require 'awesome_print'

class Legacy
  DATABASE = 'swift_udmproc_old'

  def self.initialize
    return  if @legacy
    settings = YAML.load_file( Padrino.root('config/database.yml') )[PADRINO_ENV]
    settings['database'] = DATABASE
    DataMapper.setup :legacy, settings
    @legacy = repository(:legacy).adapter
  end

  def self.select( q )
    initialize
    @legacy.select(q)
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
  end
end

def se_import( table )
  method = :"se_import_#{table}"
  send method
#rescue Exception => e
#  ap "missing #{method}, #{e}"
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

namespace :se do

  desc "load tables from old engine"
  task :import, :args do |t, args|
    #'pages news faq files collections'
    if tables = args[:args]
      tables.split(/\s+/).each{ |table| se_import(table) }
    else
      puts "USAGE: rake se:import['pages news faq files collections']\n"
      puts "   OR  rake se:import['news']\n"
      puts "  etc.\n"
    end
  end

end
