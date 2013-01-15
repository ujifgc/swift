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
          object = @object.class.to_s.underscore
          options[:label] ||= {}
          caption = options[:label].delete(:caption) || make_caption(field)
          caption += ' (' + options.delete(:brackets).to_s + ')'  if options[:brackets]
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
            if options[:code]
              opts[:class] += ' code'
              opts[:spellcheck] = 'false'
            end
            opts[:value] = options[:value] ? options[:value] : CGI.escapeHTML(@object.send(field) || '')
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
            out = ''
            (options[:options]||[]).each do |v|
              out += label_back_tag v, :for => "#{object}_#{field}_#{v}", :caption => v, :class => :checkbox do
                check_box_tag "#{object}[#{field}][]", :value => v, :id => "#{object}_#{field}_#{v}"
              end
            end
            out
          when :boolean, :checkbox, :check_box
            type = 'checkbox'
            label( field, :caption => check_box( field, :class => :check_box ), :class => :checkbox)
          when :file, :asset, :assets, :images
            loaded = @object.send(:"#{field}?")  rescue false
            tag = if loaded
              file = @object.send(field)
              caption += ' (' + I18n::t('asset_uploaded') + ')'
              unless file.content_type.blank?
                caption += tag(:br) + content_tag(:code) do
                  file.content_type
                end + tag(:br) + content_tag(:span, :class => :label) do
                  file.size.as_size
                end
              end
              content_tag( :div ) do
                if file.content_type.index('image')
                  link_to image_tag(file.url), file.url, :rel => 'box-image'
                else
                  link_to file.url, file.url
                end
              end
            else
              ''
            end
            input = if options[:multiple]
              file_field_tag "#{object}[#{field}]", options
            else
              file_field( field, options )
            end
            type = 'file'
            tag + input
          when :datetime, :date_time
            text_field field, :class => 'text_field datetime'
          else
            opts = { :class => :text_field }
            opts.merge! :value => options[:value]  if options[:value]
            text_field field, opts
          end
          error = @object.errors[field]  rescue []
          controls += content_tag( :span, error.join(', '), :class => 'help-inline' )  if error.any?          
          html = label( field, options[:label].merge( :class => 'control-label', :caption => caption ))
          html += ' ' + @template.content_tag( :div, controls, :class => :controls )
          html += ' ' + @template.content_tag( :span, options[:description], :class => :description )  unless options[:description].blank?
          klass = "control-group as_#{type}"
          klass += ' morphable'  if morphable
          klass += ' error'  if error.any?
          @template.content_tag( :div, html, :class => klass)
        end

        def group_label( field, options={} )
          caption = make_caption field
          label( field, :class => 'control-label', :caption => caption )
        end

        def inputs( *args )
          options = {}
          options = args.pop  if args.last.kind_of? Hash
          args.map{ |f| input(f, options) }.join("\n")
        end

        def submits( options={} )
          html = ''
          html += @template.submit_tag( options[:save_label] || I18n.t('padrino.admin.form.save'), :class => 'btn btn-primary', :name => 'submit' )
          html += ' ' + @template.submit_tag( options[:save_label] || I18n.t('padrino.admin.form.apply'), :class => 'btn', :name => 'apply' )
          html += ' ' + @template.submit_tag( options[:back_label] || I18n.t('padrino.admin.form.back'), :onclick => "history.back();return false", :class => 'btn' )
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
          else
            super type, options
          end
        end

      protected
        
        def make_caption( field )
          I18n.t "models.object.attributes.#{field}"
        end

      end
    end
  end
end
