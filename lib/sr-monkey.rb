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

# display date as span with tooltip
class Date
  def as_span
    "<span rel=\"tooltip\" data-original-title=\"#{self.as_date.strip}\">#{self.to_s}</span>"
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
  def self.escape(string)
    string = string.encode(::Encoding::UTF_8, :undef => :replace).force_encoding(::Encoding::BINARY)
    json = string.gsub(escape_regex) { |s| ESCAPED_CHARS[s] }
    json = %("#{json}")
    json.force_encoding(::Encoding::UTF_8)
    json
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

require 'rack/session/abstract/id'
require 'securerandom'

module Rack

  # Adds `addr` method to get ip address of a client
  class Request
    def addr
      @env['HTTP_X_FORWARDED_FOR'] || @env['REMOTE_ADDR']
    end
  end

  module Session

    class DataMapperSession
      include ::DataMapper::Resource

      storage_names[:default] = 'sessions'

      property :sid, String, :length => 20, :key => true
      property :data, Object
      property :expires_at, Time
    end

    class DataMapper < Abstract::ID

      private

      # generates new session id until it's unique for the store
      def generate_sid
        loop do
          sid = SecureRandom.hex(10)
          break sid  unless DataMapperSession.get(sid)
        end
      end

      # gets a session data from the store by session id OR returns new session id with no data
      def get_session(env, sid)
        @last_session = if sid
          @last_session_object = DataMapperSession.first :sid => sid
          [sid, @last_session_object && @last_session_object.data]
        else
          [generate_sid, nil]
        end
      end

      # puts session data in the store and returns session id if successfull
      def set_session(env, sid, session_data, options)
        session = if @last_session[1] && @last_session[0] == sid && @last_session_object
          @last_session_object
        else
          DataMapperSession.first_or_new:sid => sid
        end
        session.data = session_data
        if options[:expire_after]
          new_at = Time.now + options[:expire_after]
          session.expires_at = new_at  if new_at - session.expires_at > options[:expire_after] / 2
        else
          session.expires_at = nil
        end
        session.save && session.sid
      end

      # removes session data from the store
      def destroy_session(env, sid, options)
        DataMapperSession.all( :sid => sid ).destroy!
        generate_sid   unless options[:drop]
      end
    end
  end

end

# patch sinatra-assetpack not to mess with Rack::Test in production
class Sinatra::AssetPack::Package
  def combined
    files.inject('') do |content, file|
      content << File.read(file)
    end
  end
end
