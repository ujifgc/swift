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

# Implements #jo_json
[Array, Float, Hash, Integer, String, NilClass, TrueClass, FalseClass].each do |klass|
  klass.class_eval do
    def to_json(options = {})
      MultiJson.encode(self, options)
    end
  end
end
class Time
  def to_json(options = nil)
    xmlschema
  end
end
class Date
  def to_json(options = nil)
    strftime("%Y-%m-%d")
  end
end
class DateTime
  def to_json(options = nil)
    xmlschema
  end
end
class Object
  def to_json(options = nil)
    if respond_to? :as_json
      as_json.to_json # !!! FIXME wtf?
    else
      raise Exception, "MultiJson failed to serialize #{self.inspect}"
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

require 'rack/showexceptions'
module Sinatra
  class ShowExceptions < Rack::ShowExceptions
    def initialize(app)
      @app      = app
      @template = ERB.new(TEMPLATE)
    end

TEMPLATE = <<-HTML # :nodoc:
<!DOCTYPE html>
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
  <title><%=h exception.class %> at <%=h path %></title>

  <script type="text/javascript">
  //<!--
  function toggle(id) {
    var pre  = document.getElementById("pre-" + id);
    var post = document.getElementById("post-" + id);
    var context = document.getElementById("context-" + id);

    if (pre.style.display == 'block') {
      pre.style.display = 'none';
      post.style.display = 'none';
      context.style.background = "none";
    } else {
      pre.style.display = 'block';
      post.style.display = 'block';
      context.style.background = "#fffed9";
    }
  }

  function toggleBacktrace(){
    var bt = document.getElementById("backtrace");
    var toggler = document.getElementById("expando");

    if (bt.className == 'condensed') {
      bt.className = 'expanded';
      toggler.innerHTML = "(condense)";
    } else {
      bt.className = 'condensed';
      toggler.innerHTML = "(expand)";
    }
  }
  //-->
  </script>

<style type="text/css" media="screen">
  *                   {margin: 0; padding: 0; border: 0; outline: 0;}
  div.clear           {clear: both;}
  body                {background: #EEEEEE; margin: 0; padding: 0;
                       font-family: 'Lucida Grande', 'Lucida Sans Unicode',
                       'Garuda';}
  code                {font-family: 'Lucida Console', monospace;
                       font-size: 12px;}
  li                  {height: 18px;}
  ul                  {list-style: none; margin: 0; padding: 0;}
  ol:hover            {cursor: pointer;}
  ol li               {white-space: pre;}
  #explanation        {font-size: 12px; color: #666666;
                       margin: 20px 0 0 100px;}
/* WRAP */
  #wrap               {width: 1000px; background: #FFFFFF; margin: 0 auto;
                       padding: 30px 50px 20px 50px;
                       border-left: 1px solid #DDDDDD;
                       border-right: 1px solid #DDDDDD;}
/* HEADER */
  #header             {margin: 0 auto 25px auto;}
  #header img         {float: left;}
  #header #summary    {float: left; margin: 12px 0 0 20px; width:660px;
                       font-family: 'Lucida Grande', 'Lucida Sans Unicode';}
  h1                  {margin: 0; font-size: 36px; color: #981919;}
  h2                  {margin: 0; font-size: 22px; color: #333333;}
  #header ul          {margin: 0; font-size: 12px; color: #666666;}
  #header ul li strong{color: #444444;}
  #header ul li       {display: inline; padding: 0 10px;}
  #header ul li.first {padding-left: 0;}
  #header ul li.last  {border: 0; padding-right: 0;}
/* BODY */
  #backtrace,
  #get,
  #post,
  #cookies,
  #rack               {width: 980px; margin: 0 auto 10px auto;}
  p#nav               {float: right; font-size: 14px;}
/* BACKTRACE */
  a#expando           {float: left; padding-left: 5px; color: #666666;
                      font-size: 14px; text-decoration: none; cursor: pointer;}
  a#expando:hover     {text-decoration: underline;}
  h3                  {float: left; width: 100px; margin-bottom: 10px;
                       color: #981919; font-size: 14px; font-weight: bold;}
  #nav a              {color: #666666; text-decoration: none; padding: 0 5px;}
  #backtrace li.frame-info {background: #f7f7f7; padding-left: 10px;
                           font-size: 12px; color: #333333;}
  #backtrace ul       {list-style-position: outside; border: 1px solid #E9E9E9;
                       border-bottom: 0;}
  #backtrace ol       {width: 920px; margin-left: 50px;
                       font: 10px 'Lucida Console', monospace; color: #666666;}
  #backtrace ol li    {border: 0; border-left: 1px solid #E9E9E9;
                       padding: 2px 0;}
  #backtrace ol code  {font-size: 10px; color: #555555; padding-left: 5px;}
  #backtrace-ul li    {border-bottom: 1px solid #E9E9E9; height: auto;
                       padding: 3px 0;}
  #backtrace-ul .code {padding: 6px 0 4px 0;}
  #backtrace.condensed .system,
  #backtrace.condensed .framework {display:none;}
/* REQUEST DATA */
  p.no-data           {padding-top: 2px; font-size: 12px; color: #666666;}
  table.req           {width: 980px; text-align: left; font-size: 12px;
                       color: #666666; padding: 0; border-spacing: 0;
                       border: 1px solid #EEEEEE; border-bottom: 0;
                       border-left: 0;
                       clear:both}
  table.req tr th     {padding: 2px 10px; font-weight: bold;
                       background: #F7F7F7; border-bottom: 1px solid #EEEEEE;
                       border-left: 1px solid #EEEEEE;}
  table.req tr td     {padding: 2px 20px 2px 10px;
                       border-bottom: 1px solid #EEEEEE;
                       border-left: 1px solid #EEEEEE;}
/* HIDE PRE/POST CODE AT START */
  .pre-context,
  .post-context       {display: none;}

  table td.code       {width:750px}
  table td.code div   {width:750px;overflow:hidden}
</style>
</head>
<body>
  <div id="wrap">
    <div id="header">
      <img src="<%= env['SCRIPT_NAME'] %>/__sinatra__/500.png" alt="application error" height="161" width="313" />
      <div id="summary">
        <h1><strong><%=h exception.class %></strong> at <strong><%=h path %>
          </strong></h1>
        <h2><%=h exception.message %></h2>
        <ul>
          <li class="first"><strong>file:</strong> <code>
            <%=h frames.first.filename.split("/").last %></code></li>
          <li><strong>location:</strong> <code><%=h frames.first.function %>
            </code></li>
          <li class="last"><strong>line:
            </strong> <%=h frames.first.lineno %></li>
        </ul>
      </div>
      <div class="clear"></div>
    </div>

    <div id="backtrace" class='condensed'>
      <h3>BACKTRACE</h3>
      <p><a href="#" id="expando"
            onclick="toggleBacktrace(); return false">(expand)</a></p>
      <p id="nav"><strong>JUMP TO:</strong>
         <a href="#get-info">GET</a>
         <a href="#post-info">POST</a>
         <a href="#cookie-info">COOKIES</a>
         <a href="#env-info">ENV</a>
      </p>
      <div class="clear"></div>

      <ul id="backtrace-ul">

      <% id = 1 %>
      <% frames.each do |frame| %>
          <% if frame.context_line && frame.context_line != "#" %>

            <li class="frame-info <%= frame_class(frame) %>">
              <code><%=h frame.filename %></code> in
                <code><strong><%=h frame.function %></strong></code>
            </li>

            <li class="code <%= frame_class(frame) %>">
              <% if frame.pre_context %>
              <ol start="<%=h frame.pre_context_lineno + 1 %>"
                  class="pre-context" id="pre-<%= id %>"
                  onclick="toggle(<%= id %>);">
                <% frame.pre_context.each do |line| %>
                <li class="pre-context-line"><code><%=h line %></code></li>
                <% end %>
              </ol>
              <% end %>

              <ol start="<%= frame.lineno %>" class="context" id="<%= id %>"
                  onclick="toggle(<%= id %>);">
                <li class="context-line" id="context-<%= id %>"><code><%=
                  h frame.context_line %></code></li>
              </ol>

              <% if frame.post_context %>
              <ol start="<%=h frame.lineno + 1 %>" class="post-context"
                  id="post-<%= id %>" onclick="toggle(<%= id %>);">
                <% frame.post_context.each do |line| %>
                <li class="post-context-line"><code><%=h line %></code></li>
                <% end %>
              </ol>
              <% end %>
              <div class="clear"></div>
            </li>

          <% end %>

        <% id += 1 %>
      <% end %>

      </ul>
    </div> <!-- /BACKTRACE -->

    <div id="get">
      <h3 id="get-info">GET</h3>
      <% if req.GET and not req.GET.empty? %>
        <table class="req">
          <tr>
            <th>Variable</th>
            <th>Value</th>
          </tr>
           <% req.GET.sort_by { |k, v| k.to_s }.each { |key, val| %>
          <tr>
            <td><%=h key %></td>
            <td class="code"><div><%=h val.inspect %></div></td>
          </tr>
          <% } %>
        </table>
      <% else %>
        <p class="no-data">No GET data.</p>
      <% end %>
      <div class="clear"></div>
    </div> <!-- /GET -->

    <div id="post">
      <h3 id="post-info">POST</h3>
      <% if req.POST and not req.POST.empty? %>
        <table class="req">
          <tr>
            <th>Variable</th>
            <th>Value</th>
          </tr>
          <% req.POST.sort_by { |k, v| k.to_s }.each { |key, val| %>
          <tr>
            <td><%=h key %></td>
            <td class="code"><div><%=h val.to_s.encode('binary', :invalid => :replace, :undef => :replace) %></div></td>
          </tr>
          <% } %>
        </table>
      <% else %>
        <p class="no-data">No POST data.</p>
      <% end %>
      <div class="clear"></div>
    </div> <!-- /POST -->

    <div id="cookies">
      <h3 id="cookie-info">COOKIES</h3>
      <% unless req.cookies.empty? %>
        <table class="req">
          <tr>
            <th>Variable</th>
            <th>Value</th>
          </tr>
          <% req.cookies.each { |key, val| %>
            <tr>
              <td><%=h key %></td>
              <td class="code"><div><%=h val.inspect %></div></td>
            </tr>
          <% } %>
        </table>
      <% else %>
        <p class="no-data">No cookie data.</p>
      <% end %>
      <div class="clear"></div>
    </div> <!-- /COOKIES -->

    <div id="rack">
      <h3 id="env-info">Rack ENV</h3>
      <table class="req">
        <tr>
          <th>Variable</th>
          <th>Value</th>
        </tr>
         <% env.sort_by { |k, v| k.to_s }.each { |key, val| %>
         <tr>
           <td><%=h key %></td>
           <td class="code"><div><%=h val.to_s.encode('binary', :invalid => :replace, :undef => :replace) %></div></td>
         </tr>
         <% } %>
      </table>
      <div class="clear"></div>
    </div> <!-- /RACK ENV -->

    <p id="explanation">You're seeing this error because you RRR have
enabled the <code>show_exceptions</code> setting.</p>
  </div> <!-- /WRAP -->
  </body>
</html>
HTML
  end
end
