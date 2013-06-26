require 'ostruct'

module Swift
  module Engine
    class << self
      def registered(app)
        app.send(:include, InstanceMethods)
        app.helpers Swift::Helpers
      end
      alias :included :registered

      module InstanceMethods
        def swift
          @swift ||= OpenStruct.new
        end
      end
    end
  end
end
