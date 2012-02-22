#coding:utf-8
require 'digest/md5'

Swift.helpers do

  def element( name, *args )
    options = args.last.is_a?(Hash) ? args.pop : {}
    @opts = options
    core = partial 'elements/' + name + '/core'
    view = partial 'elements/' + name + '/view' + (options[:instance] ? "-#{options[:instance]}" : '')
    core + view
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

  def image_url( img, options = {} )
    Padrino::Helpers.image_url img, options
  end

  def parse_uub str
    @parse_level = @parse_level.to_i + 1
    return t(:parse_level_too_deep)  if @parse_level > 3

    str.gsub!(/\[(.*?)\]/) do |s|
      tag = $1
      md = tag.match /(block|image|asset|element)\s+(.*)/
      next "[#{tag}]"  unless md
      args = []
      hash = {}
      type = md[1]
      vars = md[2].scan(/["']([^"']*)["'],?|(([\S^,]+)\:\s*(["']([^"']+)["']|([^,'"\s]+)))|([^,'"\s]+),?/)
      vars.each do |v|
        case
        when v[0]
          args << v[0]
        when v[1] && v[4]
          hash.merge! v[2].to_sym => v[4]
        when v[1] && v[5]
          hash.merge! v[2].to_sym => (eval(v[5]) rescue v[5])
        when v[6]
          args << (eval(v[6]) rescue v[6])
        end
      end
      case type
      when 'block'
        block = Block.by_slug args[0]
        block ? parse_uub(block.text) : s
      when 'image'
        image_tag image_url(args[rand args.size], hash)
      when 'asset'
        link_to args[0], args[0]
      when 'element'
        element *args, hash
      end
    end
    @parse_level -= 1
    str.html
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

  module Helpers

    def self.image_url( img, options = {} )
      opt = { :size => $config[:thumb_size], :format => $config[:thumb_format] }
      img = Image.get(img)  unless img.kind_of?(Image)
      return nil            unless img.kind_of?(Image)
      return img.file       if options[:original] || options[:size] == 'original'
      format = img.file.rpartition('.')[2]
      id = img.id
      opt.merge! :format => format
      opt.merge! options
      salt = "#{id}.#{opt[:size]}.#{opt[:format]}".salt
      filename = "#{id}/#{salt}.#{opt[:size]}.#{opt[:format]}"
      "/images/cache/#{filename}"
    end

  end

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

  def salt
    Digest::MD5.hexdigest("avw6=ln73#{self}4lw;nv")[0..5]
  end

  def salt?(s)
    self == s.salt
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
