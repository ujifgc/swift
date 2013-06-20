# coding:utf-8
class String

  # Allows to connect with `/`
  # 'foo' / :bar # => 'foo/bar'
  def / (s)
    "#{self}/#{s.to_s}"
  end

end

class Symbol

  # Allows symbols to connect with `/`
  # :foo / :bar # => 'foo/bar'
  def / (s)
    "#{self.to_s}/#{s.to_s}"
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
    %(<span rel="tooltip" data-original-title="#{self.as_date.strip}">#{self.to_s}</span>)
  end
end

class Object

  # Shows size as human-readable number of bytes
  def as_size( s = nil )
    prefix = %W(Тб Гб Мб Кб б)
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

end

module Kernel
  def Logger( *args )
    if logger.respond_to? :ap
      args.each { |arg| logger.ap arg }
    else
      args.each { |arg| logger << arg.inspect }
    end
  end
end
