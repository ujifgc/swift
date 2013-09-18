module Swift
  module Helpers
    module Defer
      def placeholders
        @placeholders ||= {}
      end

      DEFERRED_ELEMENTS = Set.new(%w[Breadcrumbs PageTitle Meta]).freeze

      def defer_element( name, args, opts )
        return unless DEFERRED_ELEMENTS.include?(name)
        placeholders[name] = [ name, args, opts ]
        "%{placeholder[:#{name}]}"
      end

      def process_deferred_elements( text )
        text.to_str.gsub /(\s*)\%\{placeholder\[\:([^\]]+)\]\}/ do
          if deferred = placeholders[$2]
            output = process_element *deferred
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
