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

  def parse_content( str )
    @parse_level = @parse_level.to_i + 1
    return t(:parse_level_too_deep)  if @parse_level > 3

    str.gsub!(/\[(.*?)\]/) do |s|
      tag = $1
      md = tag.match /(page|link|block|text|image|img|file|asset|element|elem|lmn)\s+(.*)/
      next "[#{tag}]"  unless md
      args = []
      hash = {}
      type = md[1] #         0              12             3    4            5             6
      vars = md[2].scan /["']([^"']+)["'],?|(([\S^,]+)\:\s*(["']([^"']+)["']|([^,'"\s]+)))|([^,'"\s]+),?/
      # 0 for element name
      # "
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
      if hash[:title].blank?
        newtitle = if ['element', 'elem', 'lmn'].include?( type )
          args[2..-1]
        else
          args[1..-1]
        end.join(' ').strip
        hash[:title] = newtitle.blank? ? nil : newtitle
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
    @parse_level -= 1
    str
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
