require 'securerandom'

module Swift
  module ModelPlugins
    module UUID
      module ClassMethods
        def uuid!
          property :uuid, String, :length => 40

          before :create do
            self.uuid = SecureRandom.uuid
          end
        end
      end
    end
  end
end
