module Swift
  module Helpers
    module Template
      def process_page
        process_deferred_elements fragment( @page.fragment_id, :layout => :"layouts/#{@page.layout_id}" )
      end

      def element( name, *args )
        @opts = args.last.kind_of?(Hash) ? args.pop : {}
        @args = args
        defer_element( name, @args, @opts ) || process_element( name, @args, @opts )
      end

      def element_view( name, opts = {} )
        fragment name, :elements, opts
      end

      RENDER_DEFAULTS = {
        :layout => false,
        :format => :html5
      }.freeze

      def fragment( template, type = nil, opts = {} )
        opts, type = type, nil  if type.kind_of? Hash
        type ||= :fragments
        render :slim, :"#{type}/#{template}", RENDER_DEFAULTS.merge(opts)
      rescue Padrino::Rendering::TemplateNotFound, Errno::ENOENT => e
        name = template.partition('/').first
        report_error e, "EngineHelpers##{__method__}@#{__LINE__}", "[#{type.to_s.singularize.camelize} '#{name}' error: #{e.to_s.strip}]"
      end

      private

      def process_element( name, args, opts )
        @args, @opts = args, opts
        core, view = find_element name, @opts[:instance]
        @identity = fill_identity name, @opts
        catch :output do
          binding.eval File.read(core), core  if File.exists?(core)
          render :slim, view.to_sym, RENDER_DEFAULTS.merge( :views => Swift::Application.views )
        end
      rescue Padrino::Rendering::TemplateNotFound => e
        report_error e, "EngineHelpers##{__method__}@#{__LINE__}", "[Element '#{name}' error: #{e.strip}]"
      rescue Exception => e
        report_error e, "EngineHelpers##{__method__}@#{__LINE__} '#{name}'"
      end

      def find_element( name, instance = nil )
        view = "elements/#{name}/view"
        if instance
          instance_view = "#{view}-#{instance}"
          view = instance_view  if File.file?( "#{Swift::Application.views}/#{instance_view}.slim" ) 
        end
        [ "#{Swift::Application.views}/elements/#{name}/core.rb", view ]
      end

      def fill_identity( element_name, opts = {} )
        identity = { :class => element_name.dup }
        identity[:id] = opts[:id]                                 if opts[:id]
        identity[:class] << " #{opts[:class]}"                    if opts[:class]
        identity[:class] << " #{element_name}-#{opts[:instance]}" if opts[:instance]
        identity
      end
    end
  end
end
