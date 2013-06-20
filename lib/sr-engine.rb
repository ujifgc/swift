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

      def report_error( error, subsystem = 'system', fallback = nil )
        @_out_buf ||= ''.html_safe # !!! FIXME this might be fixed at tilt 1.3.8+
        if Padrino.env == :production
          messages = ''
          [ "Swift caught a runtime error at #{subsystem}",
            "Fallback for development was #{fallback||'empty'}, production displayed empty string.",
            error.message,
          ].each do |message|
            logger.error message
            messages << message + "\r\n"
          end
          error.backtrace.reject{ |e| e.match /phusion_passenger/ }.each do |step|
            logger << step
            messages << step + "\r\n"
          end
          @swift[:error_messages] ||= []
          @swift[:error_messages] << messages
          ''
        else
          fallback || raise
        end
      end

      DEFERRED_ELEMENTS = Set.new(%w[Breadcrumbs PageTitle Meta]).freeze

      def process_page
        text = fragment @page.fragment_id, :layout => @page.layout_id
        process_deferred_elements
        text.to_str.gsub /\%\{placeholder\[\:([^\]]+)\]\}/ do
          @swift[:placeholders][$1] || ''
        end
      end

      def defer_element( name, args, opts )
        @swift[:placeholders][name] = [ name, args, opts ]
        "%{placeholder[:#{name}]}"
      end

      def process_deferred_elements
        @swift[:placeholders] = @swift[:placeholders].each_with_object({}) do |(k,v), h|
          case v
          when Array
            h[k] = element( v[0], *v[1], v[2].merge( :process_defer => true ) )
          else
            h[k] = v
          end
        end
      end

      def fill_identity( opts = {} )
        identity = { :class => opts[:name] }
        identity[:id] = opts[:id]                                 if opts[:id]
        identity[:class] += " #{opts[:class]}"                    if opts[:class]
        identity[:class] += " #{opts[:name]}-#{opts[:instance]}"  if opts[:instance]
        identity
      end

      def element( name, *args )
        @opts = args.last.kind_of?(Hash) ? args.pop : {}
        @args = args

        return defer_element( name, @args, @opts )  if DEFERRED_ELEMENTS.include?(name) && @opts[:process_defer].nil?

        @opts[:name] = name
        @identity = fill_identity @opts

        core_rb = "#{Swift.views}/elements/#{name}/core.rb"
        template = "elements/#{name}/view"
        if @opts[:instance]
          instance = "#{template}-#{@opts[:instance]}"
          template = instance  if File.exists?( "#{Swift.views}/#{instance}.slim" ) 
        end

        catch :output do
          binding.eval File.read(core_rb), core_rb  if File.exists?(core_rb)
          render nil, template, :layout => false, :views => Swift.views
        end
      rescue Padrino::Rendering::TemplateNotFound => e
        report_error e, "EngineHelpers##{__method__}@#{__LINE__}", "[Element '#{name}' error: #{e.strip}]"
      rescue Exception => e
        report_error e, "EngineHelpers##{__method__}@#{__LINE__} '#{name}'"
      end

      def element_view( name, opts = {} )
        fragment name, :elements, opts
      end

      def fragment( template, type = nil, opts = {} )
        if type.kind_of? Hash
          opts = type
          type = nil
        end
        type ||= :fragments
        opts[:layout] ||= false
        render nil, "#{type}/#{template}", opts
      rescue Padrino::Rendering::TemplateNotFound, Errno::ENOENT => e
        name = template.split('/').first
        report_error e, "EngineHelpers##{__method__}@#{__LINE__}", "[#{type.to_s.singularize.camelize} '#{name}' error: #{e.strip}]"
      end

      def parse_vars( str )
        args = []
        hash = {}
        # 0 for element name
        #                     0              12             3    4            5             6
        vars = str.scan( /["']([^"']+)["'],?|(([\S^,]+)\:\s*(["']([^"']+)["']|([^,'"\s]+)))|([^,'"\s]+),?/ ) #"
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

      # matches recursive brackets
      # !!! TODO explain
      REGEX_RECURSIVE_BRACKETS = /(?<re>\[(?:(?>[^\[\]]+)|\g<re>)*\])/.freeze

      # strips text of uub code
      def strip_code( text )
        text && text.gsub(REGEX_RECURSIVE_BRACKETS, '').strip
      end

      def parse_content( str )
        @parse_level = @parse_level.to_i + 1
        return t(:parse_level_too_deep)  if @parse_level > 4
        needs_capturing = false

        str.gsub!(REGEX_RECURSIVE_BRACKETS) do |s|
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

      def url_replace( target, *args )
        hash = args.last.kind_of?(Hash) && args.last
        prefix = args.first.kind_of?(String) && args.first
        if hash
          path, _, query = target.partition ??
          hash.each do |k,v|
            k_reg = CGI.escape k.to_s
            query = query.gsub /[&^]?#{k_reg}=([^&]*)[&$]?/, ''
            query += "&#{k}=#{v}"  if v
          end
          query.gsub! /^&/, ''
          q_mark = query.present? ? ?? : ''
          target = [path, q_mark, query].join
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
