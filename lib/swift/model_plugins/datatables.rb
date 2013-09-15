module Swift
  module ModelPlugins
    module Datatables
      module ClassMethods
        def datatables!( options = {} )
          send :include, InstanceMethods

          columns = options[:columns].dup
          columns.keys.each do |k|
            columns[k][:header_title] = I18n.t("models.object.attributes.#{k}")
            case k
            when :date, :publish_at, :created_at, :updated_at, :news_rubric
              columns[k][:data] ||= {}
              columns[k][:data][:nowrap] = true
            end
          end
          @columns = columns

          def self.dynamic_columns
            @columns
          end
        end
      end

      module InstanceMethods
      end
    end
  end
end
