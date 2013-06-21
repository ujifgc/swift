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
