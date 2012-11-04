#coding:utf-8
module Padrino
  module Admin
    module Helpers

      module ViewHelpers

        # Shows full path to translation key instead of "humanizing" it
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

      module AuthenticationHelpers

        # Stores location before login
        def login_required
          unless allowed?
            if logged_in?
              redirect '/admin'
            else
              store_location! if store_location
              access_denied
            end
          end
        end

      end

    end

    module AccessControl
      class ProjectModule
        def human_name
          @name.is_a?(Symbol) ? I18n.t("padrino.admin.menu.#{@name}", :default => @name.to_s.humanize) : @name
        end
      end
    end

  end

  # Gets public folder path
  def self.public
    root + '/public'
  end

end

module Padrino
  module Helpers
    module FormHelpers

      # Adds label helper with content before the label text
      def label_back_tag(name, options={}, &block)
        options.reverse_merge!(:caption => "#{name.to_s.humanize}: ", :for => name)
        caption_text = options.delete(:caption)
        caption_text << "<span class='required'>*</span> " if options.delete(:required)
        if block_given?
          label_content = capture_html(&block) + caption_text
          concat_content(content_tag(:label, label_content, options))
        else
          content_tag(:label, caption_text, options)
        end
      end

    end
  end
end

module I18n

  # Shows full path to translation key instead of "humanizing" it
  class MissingTranslation
    module Base
      def message
        "#{keys.join('.')}"
      end
    end
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

class String

  JS_ESCAPE_MAP	= { '\\' => '\\\\', '</' => '<\/', "\r\n" => '\n', "\n" => '\n', "\r" => '\n', '"' => '\\"', "'" => "\\'" }

  # !!! FIX THIS BULLSHIT and ru_up, ru_lo, ru_cap methods
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

  # Allows to connect with `/`
  # 'foo' / :bar # => 'foo/bar'
  def / (s)
    "#{self}/#{s.to_s}"
  end

  # Renders self with global markdown renderer
  def as_html
    $markdown.render(self)
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

# Makes haml treat templates as properly encoded (respect Encoding.default_external)
module Tilt
  class HamlTemplate
    def prepare
      @data.force_encoding Encoding.default_external
      options = @options.merge(:filename => eval_file, :line => line)
      @engine = ::Haml::Engine.new(data, options)
    end
  end
end

# Makes #jo_json not to escape unicode characters with \uXXXX stuff
module ActiveSupport::JSON::Encoding
  class << self
    def escape(string)
      if string.respond_to?(:force_encoding)
        string = string.encode(::Encoding::UTF_8, :undef => :replace).force_encoding(::Encoding::BINARY)
      end
      json = string.gsub(escape_regex) { |s| ESCAPED_CHARS[s] }
      # here was scary \uXXXX pack-unpack manipulations
      json = %("#{json}")
      json.force_encoding(::Encoding::UTF_8) if json.respond_to?(:force_encoding)
    end
  end
end

# Allows amorphous resources to fill its' json with any attributes
module DataMapper
  module Resource
    def attributes=(attributes)
      model = self.model
      attributes.each do |name, value|
        case name
          when String, Symbol
            if model.allowed_writer_methods.include?(setter = "#{name}=")
              __send__(setter, value)
            else
              if self.respond_to? :json
                # !!!FIXME limit embedding by CatCard fields
                self.json[name] = value
              else
                raise ArgumentError, "The attribute '#{name}' is not accessible in #{model}"
              end
            end
          when Associations::Relationship, Property
            self.persistence_state = persistence_state.set(name, value)
        end
      end
    end
  end
end

# Adds `addr` method to get ip address of a client
module Rack
  class Request
    def addr
      @env['HTTP_X_FORWARDED_FOR'] || @env['REMOTE_ADDR']
    end
  end
end
