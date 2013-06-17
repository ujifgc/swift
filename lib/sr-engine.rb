#coding:utf-8
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
  module Helpers
    module EngineHelpers

      def report_error( error, subsystem = nil, fallback = nil )
        if Padrino.env == :production
          relevant_steps = error.backtrace.reject{ |e| e.match /phusion_passenger/ }
          message = "Swift caught a runtime error at #{subsystem||'system'}. Fallback for development was #{fallback||'empty'}, production displayed empty string."
          logger.error message
          message << "\r\nCall stack:\r\n"
          relevant_steps.each do |step|
            step = step.gsub %r{/home/.*?/}, '~/'
            message << step
            logger << step
          end
          @swift[:error_messages] ||= []
          @swift[:error_messages] << message
          ''
        else
          fallback || raise
        end
      end

      def element( name, *args )
        @opts = args.last.is_a?(Hash) ? args.pop : {}
        @args = args
        core_tpl = 'elements/' + name + '/core'
        view_tpl = 'elements/' + name + '/view'

        @identity = { :class => "#{name}" }
        @identity[:id] = @opts[:id]  if @opts[:id]
        @identity[:class] += ' ' + @opts[:class]  if @opts[:class]
        if @opts[:instance]
          view_tpl += "-#{@opts[:instance]}"
          @identity[:class] += " #{name}-#{@opts[:instance]}"
        end

        catch :output do
          if File.exists? "#{Swift.views}/#{core_tpl.gsub(/\/core$/, '/_core.slim')}"
            partial( core_tpl, :views => Swift.views )
          end
          case #!!! FIXME ugly case
          when File.exists?( "#{Swift.views}/#{view_tpl.gsub(/\/view(.*)$/, '/_view\1.slim')}" )
            partial( view_tpl, :views => Swift.views )
          when File.exists?( "#{Swift.views}/#{view_tpl.gsub(/\/view(.*)$/, '/_view.slim')}" )
            partial( view_tpl.gsub(/\/view(.*)$/, '/view'), :views => Swift.views )
          else
            raise Padrino::Rendering::TemplateNotFound, 'view'
          end
        end
      rescue Padrino::Rendering::TemplateNotFound => e
        report_error e, "EngineHelpers#element@#{__LINE__}", "[Element '#{name}' is missing #{e.to_s.gsub(/template\s+(\'.*?\').*/i, '\1')}]"
      rescue Exception => e
        report_error e, "EngineHelpers#element@#{__LINE__}"
      end

      def fragment( name, *args )
        partial 'fragments/'+name, *args, :views => Swift.views
      end
      
      def parse_vars( str )
        args = []
        hash = {}
        # 0 for element name
        #                     0              12             3    4            5             6
        vars = str.scan( /["']([^"']+)["'],?|(([\S^,]+)\:\s*(["']([^"']+)["']|([^,'"\s]+)))|([^,'"\s]+),?/ )
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
        [args, hash]    
      end

      def parse_code( html, args, content = '' )
        html.gsub(/\[(\d+)(?:\:(.*?))?\]|\[(content)\]/) do |s|
          idx = $1.to_i
          if idx > 0
            (args[idx-1] || $2).to_s
          elsif $3 == 'content'
            parse_content content
          else
            "[#{tag}]"
          end
        end
      end

      def parse_content( str )
        @parse_level = @parse_level.to_i + 1
        return t(:parse_level_too_deep)  if @parse_level > 4
        needs_capturing = false

        str.gsub!(/(?<re>\[(?:(?>[^\[\]]+)|\g<re>)*\])/) do |s|
          $1  or next s
          tag = $1[1..-2]#1                                                           2                        3
          md = tag.match /(page|link|block|text|image|img|file|asset|element|elem|lmn)((?:[\:\.\#][\w\-]*)*)\s+(.*)/
          unless md
            tags = tag.partition ' '
            code = Code.first( :slug => tags[0] )  unless tags[0][0] == '/'
            if code && code.is_single
              args, hash = parse_vars tags[2]
              next parse_code( code.html, args )
            else
              needs_capturing = true  if code
              next "[#{tag}]"
            end
          end
          type = md[1]
          args, hash = parse_vars md[-1]
          if hash[:title].blank?
            newtitle = if type == 'element'
              args[2..-1]||[]
            else
              args[1..-1]||[]
            end.join(' ').strip
            hash[:title] = newtitle.blank? ? nil : parse_content(newtitle)
          end
          md[2].to_s.scan(/[\:\.\#][\w\-]*/).each do |attr|
            case attr[0]
            when ?#
              hash[:id] ||= attr[1..-1]  
            when ?.
              if hash[:class].blank?
                hash[:class] = attr[1..-1]
              else
                hash[:class] += ' ' + attr[1..-1]
              end
            when ?:
              hash[:instance] = attr[1..-1]
            end
          end
          case type
          when 'page', 'link'
            element 'PageLink', *args, hash
          when 'block', 'table'
            element 'Block', *args, hash
          when 'image', 'img'
            element 'Image', *args, hash
          when 'file', 'asset'
            element 'File', *args, hash
          when 'element'
            element *args, hash
          end
        end
        if needs_capturing
          str.gsub!( /\[([^\s]*)\s*(.*?)\](.*?)\[\/(\1)\]/m ) do |s|
            args, hash = parse_vars $2
            code = Code.by_slug $1
            parse_code( code.html, args, $3 )
          end
        end
        @parse_level -= 1
        str
      end

      def engine_render( text )
        Markdown.render( parse_content( text ) ).html_safe
      end

      def se_url( o, method = :show )
        case o.class.name
        when 'NewsArticle'
          '/news' / method / o.slug
        when 'FormsCard'
          '/forms' / method / o.slug
        when 'Page'
          o.path
        else
          @swift[:module_root] ? @swift[:module_root] / method / o.slug : '/'
        end
      end

      def meta_for( o )
        meta = o.meta || {}
        meta['description'] ||= o.respond_to?(:info) && o.info.present? && o.info || o.title
        meta.inject(''.html_safe) do |all, pair|
          all << meta_tag( pair[1], :name => pair[0] )
        end
      end

      def url_replace( target, *args )
        hash = args.last.kind_of?(Hash) && args.last
        prefix = args.first.kind_of?(String) && args.first
        if hash
          target += '?'  unless target.index ??
          hash.each do |k,v|
            k_reg = CGI.escape k.to_s
            target = target.gsub /[\?\&]#{k_reg}=([^&]*)$/, ''
            target = target.gsub /#{k_reg}=([^&]*)\&/, ''
            target += "&#{k}=#{v}"  if v
          end
          target = target.gsub('?&',??)
        end
        if prefix
          return prefix  unless target.index ??
          target = target.gsub(/[^?]*(\?.*)/, prefix + '\1')
        end
        target
      end

    end
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
