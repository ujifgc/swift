﻿module Padrino
  module Admin
    module Helpers
      module ViewHelpers
        def padrino_admin_translate(word, default=nil)
          t("padrino.admin.#{word}", :default => default)
        end
        alias :pat :padrino_admin_translate

        def model_attribute_translate(model, attribute)
          t("models.#{model}.attributes.#{attribute}")
        end
        alias :mat :model_attribute_translate

        def model_translate(model)
          t("models.#{model}.name")
        end
        alias :mt :model_translate

      end
    end
  end

  def self.public
    root + '/public'
  end

end

module I18n
  class MissingTranslation
    module Base
      def message
        "#{keys.join('.')}"
      end
    end
  end
end

module FileUtils

  def self.mv_try( src, dst )
    return nil  if src == dst
    return nil  unless File.exists? src
    FileUtils.mkpath File.dirname(dst)
    FileUtils.mv src, dst
  rescue ArgumentError
    nil
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

class Object

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

  def as_date( d = nil )
    d = (d || self)
    return ''  unless [Date, Time, DateTime].include? d.class
    format = d.year == Date.today.year ? 'date_same_year' : 'date_other_year'
    I18n.l d, :format => I18n.t( 'time.formats.' + format )
  end

end

module Tilt
  class HamlTemplate
    def prepare
      @data.force_encoding Encoding.default_external
      options = @options.merge(:filename => eval_file, :line => line)
      @engine = ::Haml::Engine.new(data, options)
    end
  end
end
