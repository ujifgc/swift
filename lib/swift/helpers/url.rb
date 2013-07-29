require 'uri'
require 'cgi'

module Swift
  module Helpers
    module Url
      def se_url( obj, method = :show, opts = {} )
        if method.kind_of? Hash
          opts = method
          method = :show
        end
        url = case obj
        when NewsArticle
          '/news' / method / obj.slug
        when FormsCard
          '/forms' / method / obj.slug
        when Page
          obj.path
        else
          swift.module_root ? swift.module_root / method / obj.slug : '/'
        end
        if opts[:absolute]
          absolute_url url
        else
          url
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
