module Swift
  module ModelPlugins
    module Datatables
      DEFAULT_FORMAT = {
        :id          => { :code => 'mk_checkbox o', :head_class => 'last' },
        :title       => { :code => 'mk_edit o', :body_class => 'wide' },
        :date        => { :code => "o.date.kind_of?(DateTime) ? I18n.l( o.date, :format => :date ) : ''" },
        :publish_at  => { :code => "o.publish_at.kind_of?(DateTime) ? I18n.l( o.publish_at, :format => :date ) : ''" }
      }.freeze

      module ClassMethods
        def datatables!( *args )
          send :include, InstanceMethods

          options = args.extract_options!
          format = DEFAULT_FORMAT.merge(options[:format]||{})
          columns = Array(args)
          column_formats = {}

          columns.each do |key|
            column_formats[key] = format[key] || {}
            column_formats[key][:header_title_key] = "models.object.attributes.#{key}"
            case key
            when :date, :publish_at, :created_at, :updated_at, :news_rubric, :file
              column_formats[key][:data] ||= {}
              column_formats[key][:data][:nowrap] = true
            end
          end
          @dynamic_columns = column_formats

          def self.dynamic_columns
            @dynamic_columns
          end
        end
      end

      module InstanceMethods
      end
    end
  end
end
