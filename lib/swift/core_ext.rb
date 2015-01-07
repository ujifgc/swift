# coding:utf-8
class String
  # Allows to connect with `/`
  # 'foo' / :bar # => 'foo/bar'
  def / (s)
    "#{self}/#{s.to_s}".squeeze(?/)
  end

  # Transliterate the string and make it uri-friendly
  def as_slug
    Swift::Transliteration.slugize self
  end

  def normalize_lf
    self.gsub /\r\n?/m, "\n"
  end

  # case convert for cyrillic strings
  def case( dir )
    case dir
    when :up, :upper
      mb_chars.upcase.to_s
    when :lo, :low, :lower, :down
      mb_chars.downcase.to_s
    when :cap
      mb_chars.capitalize.to_s
    else
      fail ArgumentError, "wrong direction '#{dir}', use :up, :lo or :cap"
    end
  end
end

class Symbol
  # Allows symbols to connect with `/`
  # :foo / :bar # => 'foo/bar'
  def / (s)
    to_s / s
  end
end

# NilClass returns nil for any?
class NilClass
  def any?
    nil
  end
end

# display date as span with tooltip
class Date
  def as_span
    %(<span rel="tooltip" data-original-title="#{as_date.strip}">#{to_s}</span>)
  end
end

class Object
  # Shows size as human-readable number of bytes, base 1000
  def as_size( s = nil )
    prefix = %W(ТБ ГБ МБ КБ Б)
    s = (s || self).to_f
    i = prefix.length - 1
    while s > 500 && i > 0
      s /= 1000
      i -= 1
    end
    ((s > 9 || s.modulo(1) < 0.1 ? '%d' : '%.1f') % s) + ' ' + prefix[i]
  end

  # Shows size as human-readable number of bytes, base 1024
  def as_size2( s = nil )
    prefix = %W(ТиБ ГиБ МиБ КиБ Б)
    s = (s || self).to_f
    i = prefix.length - 1
    while s > 512 && i > 0
      s /= 1024
      i -= 1
    end
    ((s > 9 || s.modulo(1) < 0.1 ? '%d' : '%.1f') % s) + ' ' + prefix[i]
  end

  # Shows a date in locale-specific format
  def as_date( d = nil )
    d = (d || self)
    return ''  unless [Date, Time, DateTime].include? d.class
    format = d.year == Date.today.year ? 'date_same_year' : 'date_other_year'
    I18n.l d, :format => I18n.t( 'time.formats.' + format )
  end

  # Shows a date in locale-specific format
  def as_time( d = nil )
    d = (d || self)
    return ''  unless [Time, DateTime].include? d.class
    format = 'time_short'
    I18n.l d, :format => I18n.t( 'time.formats.' + format )
  end
end

module Kernel
  def Logger( *args )
    if logger.respond_to? :ap
      args.each { |arg| logger.ap arg }
    else
      args.each { |arg| logger << arg.inspect }
    end
  end

  def warn(*args)
    logger.warn *args
  end
end

module FileUtils
  # Tries to move a file and ignores failures
  def self.mv_try( src, dst )
    return nil  if src == dst
    return nil  unless File.exists? src
    FileUtils.mkpath File.dirname(dst)
    FileUtils.mv src, dst
  rescue ArgumentError
    nil
  end
end

if RUBY_VERSION < '2.0.0'
  class OpenStruct
    def [](name)
      @table[name.to_sym]
    end
    def []=(name, value)
      modifiable[new_ostruct_member(name)] = value
    end
  end
end
