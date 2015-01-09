#coding:utf-8
module Padrino
  module Helpers
    module FormBuilder
      class AdminFormBuilder < AbstractFormBuilder
        include TagHelpers
        include FormHelpers
        include AssetTagHelpers
        include OutputHelpers

        class FormInput
          attr_accessor :object, :field, :options, :object_type, :locale, :label_options, :template, :errors, :builder

          def initialize(object, field, template, builder, options={})
            @object = object
            @field = field
            @template = template
            @builder = builder
            @options = options.dup

            @object_type = @object.class.name.underscore
            @locale = options[:locale]
            @label_options = options[:label_options] || options[:label] || {} #!!! deprecate :label
            @label_options[:brackets] = options[:brackets] #!!! deprecate

            @errors = Array(@object.errors.delete(field))
            @errors += Array(@object.json_errors.delete(field)) if @object.respond_to?(:json_errors)
          end

          def label_tag
            tag_options = {
              :class => 'control-label',
              :caption => (SafeBuffer.new << label_caption << label_postfix),
            }
            tag_options[:for] = label_options[:for] if label_options[:for]
            builder.label(field, tag_options)
          end

          def error_span
            return '' if errors.empty?
            template.content_tag(:span, errors.join(', '), :class => 'help-inline')
          end

          def group_class
            klass = 'control-group'
            klass << " #{options[:class]}"  if options[:class].present?
            klass << ' morphable'  if options[:morphable]
            klass << ' required'  if options[:required]
            klass << ' error l'  if errors.any?
            klass
          end

          def text_area
            textarea_options = { :class => 'text_area resizable' }
            if options[:markdown]
              textarea_options[:class] << ' markdown'
              label_options[:for] = "wmd-input-#{@object.class.name.underscore}_#{field_id}"
            end
            textarea_options[:value] = if options[:code]
              textarea_options[:class] << ' code'
              textarea_options[:spellcheck] = 'false'
              options[:value]
            else
              options[:value] || begin
                value = if @object.respond_to?(field)
                  @object.send(field)
                elsif @object.respond_to?(:json)
                  @object.json[field]
                end
                CGI.escapeHTML(value.to_s)
              end
            end.to_s.html_safe
            builder.text_area(field_id, textarea_options)
          end

          def file_field
            file = @object.send(field)
            tag = if file && file.filename.present?
              label_options[:brackets] = I18n::t('asset_uploaded')
              label_options[:file_info] = file_info(file) if file.content_type.present?
              template.content_tag(:div) do
                if file.content_type.index('image')
                  template.link_to(image_tag(file.url?), file.url?, :rel => 'box-image')
                else
                  template.link_to(file.url, file.url?)
                end
              end
            else
              SafeBuffer.new
            end
            input = if options[:multiple]
              template.file_field_tag "#{object}[#{field}]", options
            else
              builder.file_field( field, options )
            end
            tag + input
          end

          def select
            select_options = options.slice(:selected, :options, :fields, :collection)
            select_options[:class] = 'select'
            blank = options[:include_blank]
            select_options[:include_blank] = (blank == true ? [' ', ''] : blank)
            html = builder.select(field, select_options)
            if options[:with_create] && (parent_relationship = @object.class.relationships[field.to_s.sub(/_id$/, '').to_sym])
              parent_model = parent_relationship.parent_model 
              create_url = "/admin/dialogs/create_parent/?parent_model=#{parent_model}&field=#{field}"
              plus_icon = template.content_tag( :i, '', :class => 'icon-plus' ) + ' ' + template.content_tag(:u, I18n.t('padrino.admin.dialog.add_parent'))
              html << ' ' << template.link_to(plus_icon, create_url, :class => 'single dialog', :'data-toggle' => :modal)
            end
            html
          end

          private

          def field_id
            @field_id ||= locale ? "#{locale}_#{field}" : field
          end

          def file_info(file)
            html = template.tag(:br)
            html << template.content_tag(:code, file.content_type)
            html << template.tag(:br)
            html << template.content_tag(:span, file.size.as_size, :class => :label)
            html
          end

          def label_postfix
            brackets = label_options[:brackets]
            info = label_options[:file_info]
            html = SafeBuffer.new
            html << ' (' + brackets + ')' if brackets
            html << ' [' + locale + ']' if locale
            html << info if info
            html
          end

          def label_caption
            return label_options[:caption] if label_options[:caption]
            field_index = if field.to_s[-1] == ']'
              field.to_s.chomp(']').gsub(/\[/,'.')
            else
              field
            end
            tr = I18n.t "models.#{object_type}.attributes.#{field_index}"
            tr = I18n.t "models.object.attributes.#{field_index}"  if tr.match(/^.?..\..+/)
          end
        end

        def input(field, options={})
          control_group = native_input(field, options.dup)
          if @object.class.respond_to?(:translated_fields) && @object.class.translated_fields.include?(field.to_s)
            locales = Option(:locales) || I18n.available_locales
            locales[1..-1].each do |locale|
              localized_options = options.merge(:locale => locale)
              translation = @object.translation_get(field, locale)
              localized_options[:value] = translation ? translation.text : ''
              control_group << "\n".html_safe << native_input(field, localized_options)
            end
          end
          control_group
        end

        def native_input(field, options)
          form_input = FormInput.new(@object, field, @template, self, options)

          controls = case options.delete(:as)
          when :text, :textarea, :text_area
            form_input.text_area
          when :password, :password_confirmation
            password_field field, :class => :password_field
          when :select, :dropdown, :variant
            form_input.select
          when :boolean, :checkbox, :check_box
            label(field, :caption => check_box(field, :class => :check_box), :class => :checkbox)
          when :file, :asset, :assets, :images
            form_input.file_field
          when :pick_image
            opts = {}
            opts[:value] = if options[:value]
              options[:value]
            else
              val = @object.respond_to?(field) ? @object.send(field) : @object.json[field]
              val.present? ? val.to_json : ''
            end
            div = hidden_field( field, opts )
            div << link_to( "#{opts[:value]} Not Implemented", '/admin/dialogs/images?pick&styleless'.html_safe, 'data-toggle' => :pick_cat )
          when :pick_asset
            opts = {}
            opts[:value] = if options[:value]
              options[:value]
            else
              val = @object.respond_to?(field) ? @object.send(field) : @object.json[field]
              val.present? ? val.to_json : ''
            end
            div = hidden_field( field, opts )
            div << link_to( "#{opts[:value]} Not Implemented", '/admin/dialogs/assets?pick&styleless'.html_safe, 'data-toggle' => :pick_cat )
          when :pick_or_upload_asset
            div = SafeBuffer.new
            folder = Folder.for_card(@object.cat_card)
            assets = Array(@object.json[field]).map{ |id| Asset.get(id) }.select(&:present?)
            div << content_tag(:div, assets.map(&:title).join(', ')) if assets.present?
            div << link_to( 'Выбрать', "/admin/dialogs/assets?pick&styleless&folder_id=#{folder.id}".html_safe, 'data-toggle' => :pick_cat, :class => 'btn btn-success' )
            div << ' '.html_safe
            div << file_field_tag("#{object}[#{field}]", options.merge(:multiple => true))
            div << hidden_field_tag("#{object}[#{field}][]", options)
          when :datetime, :date_time
            opts = {}
            opts[:class] = 'text_field datetime'
            opts[:value] = options[:value]  if options[:value]
            text_field field, opts
          when :date
            opts = {}
            opts[:class] = 'text_field date'
            opts[:value] = options[:value]  if options[:value]
            text_field field, opts
          when :time
            opts = {}
            opts[:class] = 'text_field time'
            opts[:value] = options[:value]  if options[:value]
            text_field field, opts
          when :multiple, :checkboxes, :check_boxes, :variants
            (options[:options]||[]).inject(SafeBuffer.new) do |out,v|
              out << label_back_tag( v, :for => "#{object}_#{field}_#{v}", :caption => v, :class => :checkbox ) do
                check_box_tag "#{object}[#{field}][]", :value => v, :id => "#{object}_#{field}_#{v}"
              end
            end
          else
            opts = { :class => 'text_field' }
            opts[:class] += ' long' if options[:long]
            opts[:value] = if options[:value]
              options[:value]
            else
              if @object.respond_to?( field )
                @object.send(field) || ''
              elsif @object.respond_to? :json
                @object.json[field] || ''
              else
                ''
              end
            end
            text_field field, opts
          end

          html = form_input.label_tag << ' ' << @template.content_tag(:div, controls << form_input.error_span, :class => :controls)
          html << ' ' << @template.content_tag(:span, options[:description], :class => :description) if options[:description]

          @template.content_tag(:div, html, :class => form_input.group_class)
        end

        def group_label( field, options={} )
          caption = make_caption( 'object', field )
          label( field, :class => 'control-label', :caption => caption )
        end

        def inputs( *args )
          options = {}
          options = args.pop  if args.last.kind_of? Hash
          args.inject(SafeBuffer.new) do |html,f|
            html << input(f, options) + "\n"
          end
        end

        def submits( options={} )
          html = SafeBuffer.new
          html += @template.submit_tag( options[:save_label] || I18n.t('padrino.admin.form.save'), :class => 'btn btn-primary', :name => 'submit' ) + ' '
          html += @template.submit_tag( options[:apply_label] || I18n.t('padrino.admin.form.apply'), :class => 'btn', :name => 'apply' ) + ' '
          html += @template.submit_tag( options[:back_label] || I18n.t('padrino.admin.form.back'), :onclick => "history.back();return false", :class => 'btn' )
          html += options[:append]  if options[:append]
          @template.content_tag( :div, html, :class => 'form-actions bottons' )
        end

        def submit( type, options = {} )
          case type
          when :save
            @template.submit_tag( I18n.t('padrino.admin.form.save'), :class => 'btn btn-primary', :name => 'submit' )
          when :apply
            @template.submit_tag( I18n.t('padrino.admin.form.apply'), :class => 'btn', :name => 'apply' )
          when :back
            @template.submit_tag( I18n.t('padrino.admin.form.back'), :onclick => "history.back();return false", :class => 'btn' )
          when :delete
            @template.submit_tag( I18n.t('padrino.admin.form.delete'), :class => 'btn btn-danger', :name => 'delete' )
          when :to_accepted
            @template.submit_tag( I18n.t('padrino.admin.form.to_accepted'), :class => 'btn btn-danger', :name => type )
          when :to_planned
            @template.submit_tag( I18n.t('padrino.admin.form.to_planned'), :class => 'btn btn-danger', :name => type )
          when :send
            @template.submit_tag( I18n.t('padrino.admin.form.send'), :class => 'btn', :name => 'send' )
          else
            super type, options
          end
        end

        protected

        def make_caption( model, field )
          field_index = if field.to_s[-1] == ']'
            field.to_s.chomp(']').gsub(/\[/,'.')
          else
            field
          end
          tr = I18n.t "models.#{model}.attributes.#{field_index}"
          tr = I18n.t "models.object.attributes.#{field_index}"  if tr.match(/^..\..+/)
          tr
        end

        def field_result
          result = []
          result << object_model_name if root_form?
          result
        end

        def nested_form?
          @options[:nested] && @options[:nested][:parent] && @options[:nested][:parent].respond_to?(:object)
          is_nested && object.respond_to?(:new_record?) && !object.new_record? && object.id
        end

        def object_model_name(explicit_object=object)
          return @options[:as] if root_form? && @options[:as].is_a?(Symbol)
          explicit_object.is_a?(Symbol) ? explicit_object : explicit_object.class.to_s.underscore.gsub(/\//, '_')
        end

        def root_form?
          !nested_form?
        end

        def field_name(field=nil)
          result = field_result
          result << field_name_fragment if nested_form?
          if field.to_s[-1] == ']'
            result << "[#{field.chomp(']').gsub(/\[/,'][')}]" unless field.blank?
          else
            result << "[#{field}]" unless field.blank?
          end
          result.flatten.join
        end

        def field_result
          result = []
          result << object_model_name if root_form?
          result
        end

        def nested_form?
          @options[:nested] && @options[:nested][:parent] && @options[:nested][:parent].respond_to?(:object)
          is_nested && object.respond_to?(:new_record?) && !object.new_record? && object.id
        end

        def object_model_name(explicit_object=object)
          return @options[:as] if root_form? && @options[:as].is_a?(Symbol)
          explicit_object.is_a?(Symbol) ? explicit_object : explicit_object.class.to_s.underscore.gsub(/\//, '_')
        end

        def root_form?
          !nested_form?
        end
      end
    end
  end
end
