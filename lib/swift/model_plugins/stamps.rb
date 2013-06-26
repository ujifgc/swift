module Swift
  module ModelPlugins
    module Stamps
      module ClassMethods
        # Resource has userstamps
        # It fills its creator before creating itself
        def userstamps!
          belongs_to :created_by, 'Account', :required => false
          belongs_to :updated_by, 'Account', :required => false

          before :create do |i|
            i.created_by_id = i.updated_by_id
          end
        end

        # Resource has timestamps
        def timestamps!
          property :created_at, DateTime
          property :updated_at, DateTime
        end
      end
    end
  end
end
