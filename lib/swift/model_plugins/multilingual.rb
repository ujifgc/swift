module Swift
  module ModelPlugins
    module Multilingual
      module ClassMethods
        def multilingual!(*fields)
          send :include, InstanceMethods

          @optional_fields = Array(fields.extract_options![:optional]).map(&:to_s)

          @translated_fields = Array(fields).map(&:to_s)
          @translated_fields.each do |field|
            class_eval <<-RUBY, __FILE__, __LINE__+1
              unless instance_methods.map(&:to_s).include?('original_#{field}')
                alias_method :"original_#{field}", :"#{field}"
              end

              def #{field}
                translate('#{field}')
              end
            RUBY
          end

          def self.translated_fields
            @translated_fields
          end

          def self.optional_fields
            @optional_fields
          end

          after :save do
            Array(@pending_translations).each do |locale, fields|
              fields.each do |field, value|
                translation_set(field, locale, value) if translatable?(field, locale)
              end
            end
          end
        end
      end

      module InstanceMethods
        def translate(field, locale = I18n.locale)
          if translatable?(field, locale)
            if translation = translation_get(field, locale)
              return translation.text
            else
              unless self.class.optional_fields.include?(field.to_s)
                warn("no translation to `#{locale}` found for `#{self.class.name}##{id}`: `#{field}`")
              end
            end
          end
          send(respond_to?(:"original_#{field}") ? :"original_#{field}" : field)
        end

        def translation_get(field, locale)
          Translation.first(translation_filter(field, locale))
        end

        def translation=(translations)
          self.updated_at = DateTime.now if respond_to?(:updated_at)
          @pending_translations = translations.dup
        end

        private

        def translatable?(field, locale)
          translatable_locale?(locale) && self.class.translated_fields.include?(field.to_s)
        end

        def translatable_locale?(locale)
          locales = respond_to?(:swift) ? I18n.available_locales : Array(Option(:locales) || ['ru'])
          locales[1..-1].map(&:to_sym).include?(locale.to_sym)
        end

        def translation_set(field, locale, value)
          filter = translation_filter(field, locale)
          if value && value.empty?
            return Translation.all(filter).destroy
          end
          new_value = { :text => value }
          if translation = Translation.first(filter)
            translation.update(new_value) ? translation : fail("failed to update translation due to #{translation.errors}")
          else
            Translation.create(filter.merge(new_value)) || fail("failed to create translation due to #{translation.errors}")
          end
        end

        def translation_filter(field, locale)
          {
            :locale => locale,
            :object_model => self.class.name,
            :object_id => id,
            :field => field,
          }
        end
      end
    end
  end
end
