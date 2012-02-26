module Padrino
  module Admin
    module Helpers
      module ViewHelpers
        def padrino_admin_translate(word, default=nil)
          t("padrino.admin.#{word}", :default => default)
        end
        alias :pat :padrino_admin_translate

        def model_attribute_translate(model, attribute)
          t("models.#{model}.attributes.#{attribute}")
        end
        alias :mat :model_attribute_translate

        def model_translate(model)
          t("models.#{model}.name")
        end
        alias :mt :model_translate

      end
    end
  end
end

module I18n
  class MissingTranslation
    module Base
      def message
        "#{keys.join('.')}"
      end
    end
  end
end
