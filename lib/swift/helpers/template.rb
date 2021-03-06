module Swift
  module Helpers
    module Template
      def process_page
        process_deferred_elements fragment( @page.fragment_id, :layout => :"layouts/#{@page.layout_id}" )
      end

      def element( name, *args )
        opts = Hash === args.last ? args.pop : {}
        defer_element( name, args, opts ) || process_element( name, args, opts )
      end

      def element_view( name, opts = {} )
        instance = opts[:instance] || Option(:instance)
        filename = File.join(Swift::Application.views, 'elements', "#{name}-#{instance}")
        name += '-' + instance if File.file?(filename + '.slim')
        fragment name, :elements, opts
      end

      def fragment( template, type = nil, opts = {} )
        opts, type = type, nil  if type.kind_of? Hash
        opts[:layout] ||= false
        type ||= :fragments
        render :slim, :"#{type}/#{template}", opts
      rescue Padrino::Rendering::TemplateNotFound, Errno::ENOENT => e
        name = template.partition('/').first
        report_error e, "EngineHelpers##{__method__}@#{__LINE__}", "[#{type.to_s.singularize.camelize} '#{name}' error: #{e.to_s.strip}]"
      end

      def output(data)
        throw :output, data
      end

      private

      def process_element( name, args, opts )
        began = Time.now
        return remote_element(name, *args, opts) if opts.delete(:remote)
        instance = opts[:instance] || Option(:instance)
        core, view = find_element(name, instance)
        fill_identity name, opts
        result = catch :output do
          @args, @opts = args, opts
          core_file = File.join(Swift::Application.views, core + '.rb')
          binding.eval(File.read(core_file), core_file) if File.exists?(core_file)
          view_file = File.join(Swift::Application.views, view) + '.slim'
          fail(Padrino::Rendering::TemplateNotFound, "'view.slim'") unless File.file?(view_file)
          render :slim, view.to_sym, :layout => false, :views => Swift::Application.views
        end
        logger.devel :element, began, [name, instance].compact.join('/')
        result
      rescue Padrino::Rendering::TemplateNotFound => e
        report_error e, "EngineHelpers##{__method__}@#{__LINE__}", "[Element '#{name}' error: #{e.strip}]"
      rescue Exception => e
        report_error e, "EngineHelpers##{__method__}@#{__LINE__} '#{name}'"
      end

      def find_element( name, instance = nil )
        view = "elements/#{name}/view"
        core = "elements/#{name}/core"
        if instance
          instance_view = "#{view}-#{instance}"
          view = instance_view if File.file?("#{Swift::Application.views}/#{instance_view}.slim") 
          core_view = "#{core}-#{instance}"
          core = core_view if File.file?("#{Swift::Application.views}/#{core_view}.rb")
        end
        [core, view]
      end

      def fill_identity( element_name, opts = {} )
        @identity = { :class => element_name.dup }
        @identity[:id] = opts[:id]                                 if opts[:id]
        @identity[:class] << " #{opts[:class]}"                    if opts[:class]
        @identity[:class] << " #{element_name}-#{opts[:instance]}" if opts[:instance]
      end
    end
  end
end
