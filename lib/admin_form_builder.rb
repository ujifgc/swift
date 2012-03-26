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
          caption = options[:label].delete(:caption) || I18n.t("models.object.attributes.#{field}")
          caption += ' (' + options.delete(:brackets).to_s + ')'  if options[:brackets]
          type = 'string'
          controls = case options.delete(:as)
          when :text, :textarea, :text_area
            opts = { :class => 'text_area' }
            opts[:class] += ' markdown'  if options[:markdown]
            if options[:code]
              opts[:class] += ' code'
              opts[:spellcheck] = 'false'
            end
            opts[:value] = options[:value]  if options[:value]
            type = 'textarea'
            text_area field, opts
          when :password
            password_field field, :class => :password_field
          when :select
            type = 'select'
            select field, { :class => :select }.merge( options )
          when :boolean, :checkbox
            type = 'checkbox'
            label( field, :caption => check_box( field, :class => :check_box ), :class => :checkbox)
          when :file
            loaded = @object.send(:"#{field}?")  rescue false
            tag = if loaded
              file = @object.send(field)
              caption += ' (' + I18n::t('asset_uploaded') + ')'
              content_tag( :div ) do
                if file.content_type.index('image')
                  image_tag(file.url)
                else
                  link_to file.url, file.url
                end
              end
            else
              ''
            end
            input = if options[:multiple]
              file_field_tag "#{object}[#{field}][]", options
            else
              file_field( field, options )
            end
            type = 'file'
            tag + input
          when :datetime
            text_field field, :class => 'text_field datetime'
          else
            text_field field, :class => :text_field
          end
          html = label( field, options[:label].merge( :class => 'control-label', :caption => caption ))
          html += ' ' + error_message_on( @object, field ) + ' '  if @object.errors.any?
          html += ' ' + @template.content_tag( :div, controls, :class => :controls )
          html += ' ' + @template.content_tag( :span, options[:description], :class => :description )  unless options[:description].blank?
          @template.content_tag( :div, html, :class => "control-group as_#{type}")
        end

        def inputs( *args )
          options = {}
          options = args.pop  if args.last.kind_of? Hash
          args.map{ |f| input(f, options) }.join("\n")
        end

        def submits( options={} )
          html = @template.submit_tag options[:save_label] || I18n.t('padrino.admin.form.save'), :class => 'btn btn-primary'
          html += ' ' + @template.submit_tag( options[:back_label] || I18n.t('padrino.admin.form.back'), :onclick => "history.back();return false", :class => 'btn' )
          @template.content_tag( :div, html, :class => 'form-actions bottons' )
        end

      end
    end
  end
end