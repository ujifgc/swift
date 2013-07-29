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

      def process_deferred_elements( text )
        text.to_str.gsub /(\s*)\%\{placeholder\[\:([^\]]+)\]\}/ do
          if deferred = swift.placeholders[$2]
            output = element( deferred[0], *deferred[1], deferred[2].merge( :process_deferred => true ) )
            if swift.pretty?
              $1+output.gsub(/\r|\n|\r\n/, $1)+$1
            else
              output
            end  
          else
           ''
          end
        end
      end
    end
  end
end
