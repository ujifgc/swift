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
        when NewsArticle, NewsArticles
          '/news' / method / obj.slug
        when FormsCard
          '/forms' / method / obj.slug
        when Page, Pages
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
          allowed_query_parameters = args.last.delete(:allowed_query_parameters)
          allowed_query_parameters.map!(&:to_s) if allowed_query_parameters.kind_of?(Array)
          query.dup.each do |key, value|
            query.delete(key) if allowed_query_parameters && !allowed_query_parameters.include?(key)
          end
          args.last.each do |key, value|
            if value
              query[key.to_s] = value.to_s
            else
              query.delete(key.to_s)
            end
          end
          uri.query = query.any? && URI.encode_www_form(query)
        end
        CGI.unescape(uri.to_s)
      end
    end
  end
end
