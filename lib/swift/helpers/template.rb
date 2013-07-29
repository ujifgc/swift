module Swift
  module Helpers
    module Template
      def process_page
        process_deferred_elements fragment( @page.fragment_id, :layout => :"layouts/#{@page.layout_id}" )
      end

      def element( name, *args )
        @opts = args.last.kind_of?(Hash) ? args.pop : {}
        @args = args

        return defer_element( name, @args, @opts )  if deferred?(name) && !@opts[:process_deferred]

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
          render :slim, template.to_sym, :layout => false, :views => Swift::Application.views, :format => :html5
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
        opts[:format] ||= :html5
        render :slim, :"#{type}/#{template}", opts
      rescue Padrino::Rendering::TemplateNotFound, Errno::ENOENT => e
        name = template.split('/').first
        report_error e, "EngineHelpers##{__method__}@#{__LINE__}", "[#{type.to_s.singularize.camelize} '#{name}' error: #{e.to_s.strip}]"
      end

      private

      def fill_identity( opts = {} )
        identity = { :class => opts[:name] }
        identity[:id] = opts[:id]                                 if opts[:id]
        identity[:class] += " #{opts[:class]}"                    if opts[:class]
        identity[:class] += " #{opts[:name]}-#{opts[:instance]}"  if opts[:instance]
        identity
      end
    end
  end
end
