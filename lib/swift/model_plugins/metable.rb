module Swift
  module ModelPlugins
    module Metable
      module ClassMethods
        def metable!
          send :include, InstanceMethods
          property :meta, DataMapper::Property::Json, :default => {}
        end
      end

      module InstanceMethods
        def meta
          attribute_get(:meta) || {}
        end
      end
    end
  end
end
