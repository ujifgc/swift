module Swift
  module Helpers
    module Render
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
    end
  end
end
