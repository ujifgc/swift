
module I18n
  # Shows full path to translation key instead of "humanizing" it
  class MissingTranslation
    module Base
      def message
        "#{keys.join('.')}"
      end
    end
  end
end
