module Swift
  module ModelPlugins
    module Loggable
      module ClassMethods
        def loggable!
          before :save do
            @original_content = Hash[original_attributes.select do |property, value|
              if Protocol::IGNORED_PROPERTIES.include?(property.name) || value.kind_of?(DataMapper::Resource)
                false
              else
                value != attribute_get(property.name)
              end
            end.map{ |property, value| [property.name, value] }]
          end
          after :save do
            Protocol.log( :save => self, :data => @original_content )  if @original_content.any?
          end
          after :destroy do |object|
            Protocol.log :destroy => object
          end
        end
      end
    end
  end
end
