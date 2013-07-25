require 'uri'
require 'cgi'

module Swift
  module Helpers
    module Url
      def se_url( o, method = :show )
        case o.class.name
        when 'NewsArticle'
          '/news' / method / o.slug
        when 'FormsCard'
          '/forms' / method / o.slug
        when 'Page'
          o.path
        else
          swift.module_root ? swift.module_root / method / o.slug : '/'
        end
      end

      def url_replace( target, *args )
        uri = URI.parse(URI::DEFAULT_PARSER.escape target)
        uri.path = CGI.escape(args.first)  if args.first.kind_of?(String)
        if args.last.kind_of?(Hash)
          query = uri.query ? CGI.parse(uri.query) : {}
          args.last.each{ |k,v| v ? query[k.to_s] = v.to_s : query.delete(k.to_s) }
          uri.query = query.any? && URI.encode_www_form(query)
        end
        CGI.unescape(uri.to_s)
      end
    end
  end
end
