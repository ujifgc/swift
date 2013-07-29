module Swift
  module Helpers
    module Defer
      DEFERRED_ELEMENTS = Set.new(%w[Breadcrumbs PageTitle Meta]).freeze

      def deferred?( name )
        DEFERRED_ELEMENTS.include? name
      end

      def defer_element( name, args, opts )
        swift.placeholders[name] = [ name, args, opts ]
        "%{placeholder[:#{name}]}"
      end

      def process_deferred_elements
        swift.placeholders = swift.placeholders.each_with_object({}) do |(k,v), h|
          h[k] = v.kind_of?(Array) ? element( v[0], *v[1], v[2].merge( :process_defer => true ) ) : v
        end
      end
    end
  end
end
