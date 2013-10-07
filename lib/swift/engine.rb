require 'ostruct'

module Swift
  module Engine
    module_function

    def registered(app)
      app.send(:include, InstanceMethods)
      app.helpers Swift::Helpers
    end

    module InstanceMethods
      def swift
        @swift ||= OpenStruct.new
      end
    end
  end
end
