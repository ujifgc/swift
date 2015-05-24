module Sequel::Plugins::Nozzle
  def self.apply(model, column, adapter)
    model.instance_eval do
      extend Nozzle::Adapter

      install_adapter column, adapter

      def after_save
        send "#{column}_after_save"
        super
      end

      def after_destroy
        send "#{column}_after_destroy"
        super
      end
    end
  end
end
