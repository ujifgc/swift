#coding:utf-8
module Padrino
  module Helpers
    module FormBuilder
      class AdminFormBuilder < AbstractFormBuilder
        include TagHelpers
        include AssetTagHelpers
        include OutputHelpers

        def input( field, options={} )
          html = label field, options[:label] || { :caption => I18n.t("models.object.attributes.#{field}") }
          html += ' ' + error_message_on( field ) + ' '
          html += case options[:as]
            when :text
              text_area field, :class => 'text_area' + (options[:markdown] ? ' markdown' : '')
            when :password
              password_field field, :class => :password_field
            when :select
              select field, { :class => :select }.merge( options )
            when :boolean, :checkbox
              check_box field
            when :file
              loaded = @object.send(:"#{field}?")  rescue false
              tag = if loaded
                file = @object.send(field)
                I18n::t('asset_uploaded') + content_tag( :div ) do
                  if file.content_type.index('image')
                    image_tag(file.url)
                  else
                    link_to file.url, file.url
                  end
                end
              else
                ''
              end
              tag + file_field( field )
            else
              text_field field, :class => :text_field
          end
          html += ' ' + @template.content_tag( :span, options[:descr], :class => :description )
          @template.content_tag( :div, html, :class => :group )
        end

        def inputs( *args )
          options = {}
          options = args.pop  if args.last.kind_of? Hash
          args.map{ |f| input(f, options) }.join("\n")
        end

        def submits( options={} )
          html = @template.submit_tag options[:save_label] || I18n.t('admin.form.save'), :class => :button
          html += ' ' + @template.submit_tag( options[:back_label] || I18n.t('admin.form.back'), :onclick => "history.back();return false", :class => :button )
          @template.content_tag( :div, html, :class => 'group navform wat-cf' )
        end

      end
    end
  end
end