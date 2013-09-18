module Swift
  module Helpers
    module Render
      MAX_PARSE_LEVEL = 4

      REGEX_INTERNAL_TAG = /
        \[                                                     # [
        (page|link|block|text|image|img|file|asset|element)    # 1, -- tag name
        (                                                      # 2, -- identity
          (?:[\:\.\#][\w\-]*)*                                 #
        )                                                      #
        \s+                                                    #
        (.*)                                                   # 3, -- arguments
        \]                                                     # ]
      /x.freeze

      REGEX_IDENTITY = /
        [\:\.\#]    # prefix :.#
        [\w\-]*     # identity name
      /x.freeze

      REGEX_RECURSIVE_BRACKETS = /
        (?<re>             #
          \[               #
          (?:              #
            (?>[^\[\]]+)   # 1
            |              #
            \g<re>         #
          )*               #
          \]               #
        )                  #
      /x.freeze

      REGEX_VARS = /
        ["']([^"']+)["'],? |           # 0, -- "smth",
        (                              # 1
          ([\S^,]+)\:\s*               # 2
          (                            # 3
            ["']([^"']+)["'] |         # 4
            ([^,'"\s]+)                # 5 "'
          )                            # "
        ),? |                          # 1, -- key: "smth",
        ([^'"\s]+)                     # 6, -- sm, th "'
      /x.freeze

      INTERNAL_TAGS = {
        'page'  => 'PageLink',
        'link'  => 'PageLink',
        'block' => 'Block',
        'table' => 'Block',
        'image' => 'Image',
        'img'   => 'Image',
        'file'  => 'File',
        'asset' => 'File',
        'element' => :self,
      }.freeze

      def parse_content( text )
        limit_recursion do |flags|
          draft = text.gsub(REGEX_RECURSIVE_BRACKETS) do |tag|
            dispatch_tag tag, flags
          end
          capture_tag_content draft, flags
        end
      end

      def strip_code( text )
        text && text.gsub(REGEX_RECURSIVE_BRACKETS, '').strip
      end

      def engine_render( text )
        Markdown.render( parse_content( text ) ).html_safe
      end

      private

      def dispatch_tag( tag, flags )
        internal_tag(tag.match(REGEX_INTERNAL_TAG)) || external_tag(tag, flags)
      end

      def dispatch_element( tag_name, args, opts )
        element_name = INTERNAL_TAGS[tag_name]  or return
        element_name = args.shift  if element_name == :self
        element element_name, *args, opts
      end

      def internal_tag( data )
        return  unless data
        tag_name, identity, vars = data[1], data[2], data[-1]
        args, opts = parse_vars vars
        opts[:title] = detect_title( tag_name, args )  if opts[:title].blank?
        detect_identity identity, opts
        dispatch_element tag_name, args, opts
      end

      def external_tag( tag, flags )
        tag_name, _, vars = tag[1..-2].partition ' '
        code = Code.first( :slug => tag_name )  unless tag_name[0] == '/'
        if code && code.is_single
          args, opts = parse_vars vars
          [ parse_code( code.html, args ) ]
        else
          flags[:needs_capturing] = true  if code
          tag
        end
      end

      def detect_identity( identity, opts )
        identity.to_s.scan(REGEX_IDENTITY).each do |attr|
          prefix, name = attr[0], attr[1..-1]
          case prefix
          when '#'
            opts[:id] ||= name
          when '.'
            if opts[:class].blank?
              opts[:class] = name
            else
              opts[:class] << ' ' << name
            end
          when ':'
            opts[:instance] = name
          end
        end
      end

      def detect_title( type, args )
        newtitle = if type == 'element'
          args[2..-1]||[]
        else
          args[1..-1]||[]
        end.join(' ').strip
        parse_content(newtitle)  if newtitle.present?
      end

      def capture_tag_content( str, flags )
        return str  unless flags[:needs_capturing]
        str.gsub( /\[([^\s]*)\s*(.*?)\](.*?)\[\/(\1)\]/m ) do |s|
          args, _ = parse_vars $2
          code = Code.by_slug $1
          parse_code code.html, args, $3
        end
      end

      def limit_recursion
        @parse_level ||= 0
        @parse_level += 1
        raise SystemStackError, 'parse level too deep'  if @parse_level > MAX_PARSE_LEVEL
        result = yield({})
        @parse_level -= 1
        result
      end

      def parse_vars( str )
        args = []
        opts = {}
        str.scan(REGEX_VARS).each do |v|
          case
          when v[0]
            args << v[0].to_s
          when v[1] && v[4]
            opts.merge! v[2].to_sym => v[4]
          when v[1] && v[5]
            opts.merge! v[2].to_sym => v[5]
          when v[6]
            args << v[6]
          end
        end
        [args, opts]    
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
    end
  end
end
