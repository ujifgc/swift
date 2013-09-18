module Padrino
  module Helpers
    module FormBuilder
      class SwiftFormBuilder < AdminFormBuilder
        def inquiry( field, options={} )
          object = @object.class.to_s.underscore
          options[:label] ||= {}
          caption = options[:label].delete(:caption) || make_caption(field)
          caption += ' (' + options.delete(:brackets).to_s + ')'  if options[:brackets]
          type = 'string'
          morphable = options.delete :morphable
          options.delete :options  if options[:options] && options[:options].empty?
          controls = case options.delete(:as)
          when :multiple, :checkboxes, :check_boxes, :variants
            type = 'multiple'
            (options[:options]||[]).inject(''.html_safe) do |out,v|
              out << label_back_tag( v, :for => "#{object}_#{field}_#{v}", :caption => v, :class => :checkbox ) do
                check_box_tag "#{object}[#{field}][]", :value => v, :id => "#{object}_#{field}_#{v}"
              end
            end
          when :radio, :select, :dropdown, :variant
            type = 'radio'
            (options[:options]||[]).inject(''.html_safe) do |out,v|
              out << label_back_tag( v, :for => "#{object}_#{field}_#{v}", :caption => v, :class => :radio ) do
                radio_button_tag "#{object}[#{field}]", :value => v, :id => "#{object}_#{field}_#{v}"
              end
            end
          else
           ''.html_safe
          end
          error = @object.errors[field]  rescue []
          controls += content_tag( :span, error.join(', '), :class => 'help-inline' )  if error.any?          
          html = controls + ' '.html_safe
          html += @template.content_tag( :span, options[:description], :class => :description )  unless options[:description].blank?
          klass = "control-group as_#{type}"
          klass += ' morphable'  if morphable
          klass += ' error'  if error.any?
          @template.content_tag( :div, html, :class => klass)
        end

        protected

        def make_caption( field )
          field
        end
      end
    end
  end
end
