#coding:utf-8
class HttpRouter::Request
  def initialize(path, rack_request)
    @rack_request = rack_request
    @path = Rack::Utils.unescape(path).split(/\//)
    @path.shift if @path.first == ''
    @path.push('') if path[-1] == ?/
    @extra_env = {}
    @params = []
    @acceptable_methods = Set.new
  end
end

module Markdown
  MarkdownExtras = {
    :autolink => true,
    :space_after_headers => true,
    :tables => true,
    :strikethrough => true,
    :no_intra_emphasis => true,
    :superscript => true,
  }

  # Makes MixedHTML class which will render markdown inside block-level HTML tags
  class LiteHTML < Redcarpet::Render::HTML
    def paragraph(text)
      text
    end
  end

  class MixedHTML < Redcarpet::Render::HTML
    HTML_TAG_SPLIT = /\A(\<([^>\s]*)(?:\s+[^>]*)*\>)(.*)(\<\/\2(?:\s+[^>]*)?\>\n*)\z/m.freeze
    def block_html(raw_html)
      if data = raw_html.match( HTML_TAG_SPLIT )
        data[1] + LiteParser.render(data[3]) + data[4]
      else
        raw_html
      end
    end
  end  

  LiteParser = Redcarpet::Markdown.new( LiteHTML, MarkdownExtras )
  MixedParser = Redcarpet::Markdown.new( MixedHTML, MarkdownExtras )

  def self.render( text )
    MixedParser.render text
  end
end

module Padrino
  module Admin
    module Helpers
      module ViewHelpers
        # Shows full path to translation key instead of "humanizing" it
        def padrino_admin_translate(word, default=nil)
          t("padrino.admin.#{word}", :default => default).html_safe
        end
        alias :pat :padrino_admin_translate

        def model_attribute_translate(model, attribute)
          t("models.#{model}.attributes.#{attribute}").html_safe
        end
        alias :mat :model_attribute_translate

        def model_translate(model)
          t("models.#{model}.name").html_safe
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
              store_location!  if store_location && !request.env['REQUEST_URI'].match(%r{(?:/assets|stylesheets/|/javascripts/).*(?:\.css|\.js)$})
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

  # allow params keys to be utf-8 in multipart mode
  module Utils
    class KeySpaceConstrainedParams
      alias_method :old_to_params_hash, :to_params_hash
      def to_params_hash
        Hash[old_to_params_hash.map{ |k,v| [k.dup.force_encoding('utf-8'), v] }]
      end
    end
  end

  # Adds `addr` method to get ip address of a client
  class Request
      def parse_multipart(env)
        Rack::Multipart.parse_multipart(env)
      end
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
          session.expires_at = new_at  if session.expires_at.nil? || (new_at - session.expires_at > options[:expire_after] / 2)
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

class Padrino::Rendering::TemplateNotFound
  def strip
    'missing ' + to_s.gsub(/template\s+(\'.*?\').*/i, '\1').gsub(/\/elements\/[^\/]+\//, '')
  end
end

require 'rack/showexceptions'
module Sinatra
  class ShowExceptions < Rack::ShowExceptions
    def initialize(app)
      @app      = app
      @template = ERB.new( File.read 'lib/error-500.erb' )
    end
  end
end
