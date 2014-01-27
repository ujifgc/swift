class Padrino::Rendering::TemplateNotFound
  def strip
    'missing ' + to_s.gsub(/template\s+(\'.*?\').*/i, '\1').gsub(/\/elements\/[^\/]+\//, '')
  end
end

module Padrino
  class Application
    def self.route_verbs(verbs, *args, &block)
      verbs.each do |verb|
        send(verb, *args, &block)
      end
    end
  end

  def self.public(*args)
    root('public', *args)
  end

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
