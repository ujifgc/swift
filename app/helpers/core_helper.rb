#coding:utf-8
require 'digest/md5'

Swift.helpers do

  def element( name, *args )
    @opts = args.last.is_a?(Hash) ? args.pop : {}
    @args = args
    core_file = 'elements/' + name + '/core'
    view_file = 'elements/' + name + '/view' + (@opts[:instance] ? "-#{@opts[:instance]}" : '')
    core = partial( core_file )  if File.exists?( "#{Swift.root}/views/elements/#{name}/_core.haml" )
    if @swift[:skip_view][name]
      core
    else
      partial( view_file )
    end
  rescue Padrino::Rendering::TemplateNotFound
    "[Element '#{name}' missing]"
  end

  def fragment( name, *args )
    partial 'fragments/'+name, *args
  end
  
  def parse_vars( str )
    args = []
    hash = {}
    # 0 for element name
    #                     0              12             3    4            5             6
    vars = str.scan( /["']([^"']+)["'],?|(([\S^,]+)\:\s*(["']([^"']+)["']|([^,'"\s]+)))|([^,'"\s]+),?/ )    #"
    vars.each do |v|
      case
      when v[0]
        args << v[0].to_s
      when v[1] && v[4]
        hash.merge! v[2].to_sym => v[4]
      when v[1] && v[5]
        hash.merge! v[2].to_sym => v[5]
      when v[6]
        args << v[6]
      end
    end
    [args, hash]    
  end

  def parse_code( html, args, content = '' )
    html.gsub(/\[(\d+)(?:\:(.*?))?\]|\[(content)\]/) do |s|
      idx = $1.to_i
      if idx > 0
        (args[idx-1] || $2).to_s
      elsif $3 == 'content'
        parse_content content
      else
        "[#{tag}]"
      end
    end
  end

  def parse_content( str )
    @parse_level = @parse_level.to_i + 1
    return t(:parse_level_too_deep)  if @parse_level > 4
    needs_capturing = false

    str.gsub!(/(?<re>\[(?:(?>[^\[\]]+)|\g<re>)*\])/) do |s|
      tag = $1[1..-2]
      md = tag.match /(page|link|block|text|image|img|file|asset|element|elem|lmn)\s+(.*)/
      unless md
        tags = tag.partition ' '
        code = Code.by_slug tags[0]  unless tags[0][0] == '/'
        if code && code.is_single
          args, hash = parse_vars tags[2]
          next parse_code( code.html, args )
        else
          needs_capturing = true  if code
          next "[#{tag}]"
        end
      end
      type = md[1]
      args, hash = parse_vars md[2]
      if hash[:title].blank?
        newtitle = if ['element', 'elem', 'lmn'].include?( type )
          args[2..-1]
        else
          args[1..-1]
        end.join(' ').strip
        hash[:title] = newtitle.blank? ? nil : parse_content(newtitle)
      end
      case type
      when 'page', 'link'
        element 'PageLink', args[0], hash
      when 'block', 'text'
        element 'Block', args[0], hash
      when 'image', 'img'
        element 'Image', args[0], hash
      when 'file', 'asset'
        element 'File', args[0], hash
      when 'element', 'elem', 'lmn'
        element *args, hash
      end.strip
    end
    if needs_capturing
      logger << str
      str.gsub!( /\[([^\s]*)\s+(.*?)\](.*)\[\/(\1)\]/ ) do |s|
        #throw [$1, $2, $3, $4, $5, $6]
        args, hash = parse_vars $2
        #throw [args, hash]
        code = Code.by_slug $1
        parse_code( code.html, args, $3 )
      end
    end
    @parse_level -= 1
    str
  end

  def render_text( text )
    parse_content(text).html
  end

  def div_open( opt )
    "<div class='#{opt.to_s}'>"
  end

  def div_close( opt )
    '</div>'
  end

  def se_url( o )
    case o.class.name
    when 'NewsArticle'
      '/news/show/'+o.slug
    else
      '/'
    end
  end

end
