#coding:utf-8
module Padrino
  module Helpers
    module FormBuilder
      class AdminFormBuilder < AbstractFormBuilder
        include TagHelpers
        include FormHelpers
        include AssetTagHelpers
        include OutputHelpers

        def input( field, options={} )
          control_group = native_input(field, options.dup)
          if @object.class.respond_to?(:translated_fields) && @object.class.translated_fields.include?(field.to_s)
            locales = Option(:locales) || I18n.available_locales
            locales[1..-1].each do |locale|
              localized_options = options.merge(:locale => locale, :brackets => locale)
              translation = @object.translation_get(field, locale)
              localized_options[:value] = translation ? translation.text : ''
              control_group << "\n".html_safe << native_input(field, localized_options)
            end
          end
          control_group
        end

        def native_input(field, options)
          object = @object.class.to_s.underscore
          options[:label] ||= {}
          caption = ''.html_safe
          caption << (options[:label].delete(:caption) || make_caption(object, field))
          caption << ' (' + options.delete(:brackets).to_s + ')'  if options[:brackets]
          locale = options.delete(:locale)
          field = "#{locale}_#{field}" if locale
          type = 'string'
          morphable = options.delete :morphable
          options.delete :options  if options[:options] && options[:options].empty?
          controls = case options.delete(:as)
          when :text, :textarea, :text_area
            opts = { :class => 'text_area resizable' }
            if options[:markdown]
              opts[:class] += ' markdown'
              options[:label].merge!( :for => "wmd-input-#{@object.class.name.underscore}_#{field}" )
            end
            opts[:value] = if options[:code]
              opts[:class] += ' code'
              opts[:spellcheck] = 'false'
              options[:value] || ''
            else
              if options[:value]
                options[:value]
              else
                if @object.respond_to?( field )
                  CGI.escapeHTML(@object.send(field) || '')
                elsif @object.respond_to? :json
                  CGI.escapeHTML(@object.json[field] || '')
                else
                  ''
                end
              end
            end.to_s.html_safe
            type = 'textarea'
            text_area field, opts
          when :password, :password_confirmation
            password_field field, :class => :password_field
          when :select, :dropdown, :variant
            type = 'select'
            if options[:include_blank]
              unless [String, Array].include? options[:include_blank].class
                options[:include_blank] = [' ', '']
              end
            end
            tag = select field, { :class => :select }.merge( options )
            parent_field = field.to_s.gsub(/_id$/,'').to_sym
            add = if @object.class.relationships[parent_field] && options[:with_create]
              parent_model = @object.class.relationships[parent_field].parent_model 
              # !!!FIX the url
              link_to content_tag( :i, '', :class => 'icon-plus' ) + ' ' + content_tag(:u, I18n.t('padrino.admin.dialog.add_parent')), "/admin/dialogs/create_parent/?parent_model=#{parent_model}&field=#{field}", :class => 'single dialog', :'data-toggle' => :modal
            else
              ''
            end
            tag + ' ' + add
          when :multiple, :checkboxes, :check_boxes, :variants
            type = 'multiple'
            (options[:options]||[]).inject(''.html_safe) do |out,v|
              out << label_back_tag( v, :for => "#{object}_#{field}_#{v}", :caption => v, :class => :checkbox ) do
                check_box_tag "#{object}[#{field}][]", :value => v, :id => "#{object}_#{field}_#{v}"
              end
            end
          when :boolean, :checkbox, :check_box
            type = 'checkbox'
            label( field, :caption => check_box( field, :class => :check_box ), :class => :checkbox)
          when :file, :asset, :assets, :images
            file = @object.send(field)  rescue false
            tag = if file && file.filename.present?
              caption << ' (' << I18n::t('asset_uploaded') << ')'
              if file.content_type.present?
                caption += tag(:br) + content_tag(:code, file.content_type) + tag(:br) + content_tag(:span, file.size.as_size, :class => :label)
              end
              content_tag( :div ) do
                if file.content_type.index('image')
                  link_to image_tag(file.url?), file.url?, :rel => 'box-image'
                else
                  link_to file.url, file.url?
                end
              end
            else
              ''.html_safe
            end
            input = if options[:multiple]
              file_field_tag "#{object}[#{field}]", options
            else
              file_field( field, options )
            end
            type = 'file'
            tag + input
          when :pick_image
            # !!! FIXME html_safe should be NOT needed. this is link_to or url bug
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
            div = ''.html_safe
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
          error = Array(@object.errors.delete(field))
          error += Array(@object.json_errors.delete(field))  if @object.respond_to? :json_errors
          controls += content_tag( :span, error.join(', '), :class => 'help-inline' )  if error.any?          
          # ramove , :id => nil after 0.12.2
          html = label( field, options[:label].merge( :class => 'control-label', :caption => caption, :id => nil ) ) + ' '
          html += @template.content_tag( :div, controls, :class => :controls ) + ' '
          html += @template.content_tag( :span, options[:description], :class => :description )  unless options[:description].blank?
          klass = "control-group as_#{type}"
          klass += " #{options[:class]}"  if options[:class].present?
          klass += ' morphable'  if morphable
          klass += ' required'  if options[:required]
          klass += ' error l'  if error.any?
          @template.content_tag( :div, html, :class => klass)
        end

        def group_label( field, options={} )
          caption = make_caption( 'object', field )
          label( field, :class => 'control-label', :caption => caption )
        end

        def inputs( *args )
          options = {}
          options = args.pop  if args.last.kind_of? Hash
          args.inject(''.html_safe) do |html,f|
            html << input(f, options) + "\n"
          end
        end

        def submits( options={} )
          html = ''.html_safe
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
