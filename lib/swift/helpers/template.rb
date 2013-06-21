module Swift
  module Helpers
    module Template
      def process_page
        text = fragment @page.fragment_id, :layout => @page.layout_id
        process_deferred_elements
        text.to_str.gsub /\%\{placeholder\[\:([^\]]+)\]\}/ do
          @swift[:placeholders][$1] || ''
        end
      end

      def fill_identity( opts = {} )
        identity = { :class => opts[:name] }
        identity[:id] = opts[:id]                                 if opts[:id]
        identity[:class] += " #{opts[:class]}"                    if opts[:class]
        identity[:class] += " #{opts[:name]}-#{opts[:instance]}"  if opts[:instance]
        identity
      end

      def element( name, *args )
        @opts = args.last.kind_of?(Hash) ? args.pop : {}
        @args = args

        return defer_element( name, @args, @opts )  if deferred?(name) && @opts[:process_defer].nil?

        @opts[:name] = name
        @identity = fill_identity @opts

        core_rb = "#{Swift::Application.views}/elements/#{name}/core.rb"
        template = "elements/#{name}/view"
        if @opts[:instance]
          instance = "#{template}-#{@opts[:instance]}"
          template = instance  if File.exists?( "#{Swift::Application.views}/#{instance}.slim" ) 
        end

        catch :output do
          binding.eval File.read(core_rb), core_rb  if File.exists?(core_rb)
          render nil, template, :layout => false, :views => Swift::Application.views
        end
      rescue Padrino::Rendering::TemplateNotFound => e
        report_error e, "EngineHelpers##{__method__}@#{__LINE__}", "[Element '#{name}' error: #{e.strip}]"
      rescue Exception => e
        report_error e, "EngineHelpers##{__method__}@#{__LINE__} '#{name}'"
      end

      def element_view( name, opts = {} )
        fragment name, :elements, opts
      end

      def fragment( template, type = nil, opts = {} )
        if type.kind_of? Hash
          opts = type
          type = nil
        end
        type ||= :fragments
        opts[:layout] ||= false
        render nil, "#{type}/#{template}", opts
      rescue Padrino::Rendering::TemplateNotFound, Errno::ENOENT => e
        name = template.split('/').first
        report_error e, "EngineHelpers##{__method__}@#{__LINE__}", "[#{type.to_s.singularize.camelize} '#{name}' error: #{e.strip}]"
      end
    end
  end
end
