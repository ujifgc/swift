class Padrino::Rendering::TemplateNotFound
  def strip
    'missing ' + to_s.gsub(/template\s+(\'.*?\').*/i, '\1').gsub(/\/elements\/[^\/]+\//, '')
  end
end

module Padrino
  module Admin
    module Helpers
      module ViewHelpers
        # Shows full path to translation key instead of "humanizing" it
        def padrino_admin_translate(word, default=nil)
          t("padrino.admin.#{word}", :default => default).html_safe
        end
        alias :pat :padrino_admin_translate

        def model_attribute_translate(model, attribute)
          t("models.#{model}.attributes.#{attribute}").html_safe
        end
        alias :mat :model_attribute_translate

        def model_translate(model)
          t("models.#{model}.name").html_safe
        end
        alias :mt :model_translate
      end

      module AuthenticationHelpers
        # Stores location before login
        def login_required
          unless allowed?
            if logged_in?
              redirect '/admin'
            else
              store_location!  if store_location && !request.env['REQUEST_URI'].match(%r{(?:/assets|stylesheets/|/javascripts/).*(?:\.css|\.js|\.png)$})
              access_denied
            end
          end
        end
      end
    end

    module AccessControl
      class ProjectModule
        def human_name
          @name.is_a?(Symbol) ? I18n.t("padrino.admin.menu.#{@name}", :default => @name.to_s.humanize) : @name
        end
      end
    end

  end

  # Gets public folder path
  def self.public
    root + '/public'
  end

end

module Padrino
  module Helpers
    module FormHelpers
      # Adds label helper with content before the label text
      def label_back_tag(name, options={}, &block)
        options.reverse_merge!(:caption => "#{name.to_s.humanize}: ", :for => name)
        caption_text = options.delete(:caption)
        caption_text << "<span class='required'>*</span> " if options.delete(:required)
        if block_given?
          label_content = capture_html(&block) + caption_text
          concat_content(content_tag(:label, label_content, options))
        else
          content_tag(:label, caption_text, options)
        end
      end
    end
  end
end
