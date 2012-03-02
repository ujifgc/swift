#coding:utf-8
require 'digest/md5'

Swift.helpers do

  def element( name, *args )
    @opts = args.last.is_a?(Hash) ? args.pop : {}
    @args = args
    core_file = 'elements/' + name + '/core'
    view_file = 'elements/' + name + '/view' + (@opts[:instance] ? "-#{@opts[:instance]}" : '')
    core = File.exists?( "#{Swift.root}/views/elements/#{name}/_core.haml" ) ? partial( core_file ) : ''
    result = core + partial( view_file )
    @opts[:raw] ? result : parse_uub( result )
  rescue Padrino::Rendering::TemplateNotFound
    "[Element '#{name}' missing]"
  end

  def fragment( name, *args )
    partial 'fragments/'+name, *args
  end

  def init_instance
    swift = {}
    swift[:path_ids] = []

    full = request.env['PATH_INFO']
    path = full.gsub /\/\d+/, ''
    names = path.split '/'
    names = ['']  if names.empty?
    url = '/'
    names.each do |name|
      url += (url[-1]=='/' ? '' : '/') + "#{name}"
      page = Page.first :path => url
      swift[:path_ids] << page.id  if page && !url.blank?
    end

    swift
  end

  def parse_uub( str )
    @parse_level = @parse_level.to_i + 1
    return t(:parse_level_too_deep)  if @parse_level > 3

    str.gsub!(/\[(.*?)\]/) do |s|
      tag = $1
      md = tag.match /(block|text|image|img|file|asset|element|elem|lmn)\s+(.*)/
      next "[#{tag}]"  unless md
      args = []
      hash = {}
      type = md[1] #         0              12             3    4            5             6
      vars = md[2].scan /["']([^"']+)["'],?|(([\S^,]+)\:\s*(["']([^"']+)["']|([^,'"\s]+)))|([^,'"\s]+),?/
      # 0 for element name
      # 
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
      hash.merge!( :title => args[1..-1].join(' ').strip )  if hash[:title].blank?
      case type
      when 'block', 'text'
        element 'Block', args[0], hash
      when 'image', 'img'
        element 'Image', args[0], hash
      when 'file', 'asset'
        element 'File', args[0], hash
      when 'element', 'elem', 'lmn'
        element *args, hash
      end
    end
    @parse_level -= 1
    str
  end

  def as_size( s )
    prefix = %W(TiB GiB MiB KiB B)
    s = s.to_f
    i = prefix.length - 1
    while s > 512 && i > 0
      s /= 1024
      i -= 1
    end
    ((s > 9 || s.modulo(1) < 0.1 ? '%d' : '%.1f') % s) + ' ' + prefix[i]
  end

end

module Padrino

  def self.public
    root + '/public'
  end

end

class String

  JS_ESCAPE_MAP	= { '\\' => '\\\\', '</' => '<\/', "\r\n" => '\n', "\n" => '\n', "\r" => '\n', '"' => '\\"', "'" => "\\'" }
  LO = %w(а б в г д е ё ж з и й к л м н о п р с т у ф х ц ч ш щ ъ ы ь э ю я)
  UP = %W(А Б В Г Д Е Ё Ж З И Й К Л М Н О П Р С Т У Ф Х Ц Ч Ш Щ Ъ Ы Ь Э Ю Я)

  def ru_up
    if idx = LO.index(self)
      UP[idx]
    else
      self.upcase
    end
  end

  def ru_lo
    if idx = UP.index(self)
      LO[idx]
    else
      self.downcase
    end
  end

  def ru_cap
    if self.length > 0
      self[0].ru_up + self[1..-1]
    else
      self
    end
  end

  def / (s)
    "#{self}/#{s.to_s}"
  end

  def html
    $markdown.render(self)
  end

end

class Symbol
  def / (s)
    "#{self.to_s}/#{s.to_s}"
  end
end
