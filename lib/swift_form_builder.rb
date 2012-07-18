module Padrino
  module Helpers
    module FormBuilder
      class SwiftFormBuilder < AdminFormBuilder
      protected
        def make_caption( field )
          field
        end
      end
    end
  end
end