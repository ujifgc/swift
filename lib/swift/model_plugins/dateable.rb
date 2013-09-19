module Swift
  module ModelPlugins
    module Dateable
      module ClassMethods
        # Resource is dateable
        # It has date property and does some fixing before save
        def dateable!
          property :date, DateTime, :required => true

          before :valid? do |i|
            self.date = nil  if date.blank?
          end
        end
      end
    end
  end
end
