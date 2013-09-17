module Swift
  module Helpers
    module Init
      def init_page
        path = swift.path
        path = path.chomp('/')  if path.length > 1
        page = Page.first( :conditions => [ "? LIKE IF(is_module,CONCAT(path,'%'),path)", path ], :order => :path.desc )
        params.reverse_merge! Rack::Utils.parse_query(page.params)  if page && page.params.present?

        if page && page.parent_id && page.fragment_id == 'page' && page.text.blank?
          first_child = page.children.first( :order => :position )
          redirect first_child.path  if first_child
        end

        if page && page.is_module
          swift.module_root = page.path  # => /news
          swift.slug = case path[page.path.length]
          when '/'  # /news/some-slug
            path[(page.path.length+1)..-1] # => some-slug
          when nil  # /news
            ''
          else      # /newsbar
            page = nil
          end
        end

        unless page
          root = Page.first( :parent => nil )
          swift.path_pages.unshift root
          swift.path_ids.unshift root.id
        end
        
        swift.resource = page
        @page = page

        while page
          swift.path_pages.unshift page
          swift.path_ids.unshift page.id
          page = page.parent
        end

        @page
      end

      def init_error( errno )
        root = Page.first( :parent => nil )
        page = Page.first :path => "/error/#{errno}"
        page ||= Page.new :title => "Error #{errno}", :text => "page /error/#{errno} not found"
        swift.path_pages = [ root ]
        swift.path_ids = [ root.id ]
        @page = page
      end

      def init_swift
        return  if @_inited
        init_folders
        init_media
        init_http
        @_inited = true
      end

      private

      def init_http
        swift.http_method = request.env['REQUEST_METHOD']
        swift.host = request.env['SERVER_NAME']
        swift.uri = "/#{params[:request_uri]}"
        swift.path = swift.uri.partition('?').first
        swift.path_pages = []
        swift.path_ids = []
      end

      def init_folders
        swift.root = Swift::Application.root
        swift.public = Swift::Application.public_folder
        swift.views = Swift::Application.views
      end

      def init_media
        media = params.has_key?('print') ? 'print' : 'screen'
        swift.send("#{media}?=", media)
        swift.media = media
        swift.send("pretty?=", Padrino.env == :development)
      end
    end
  end
end
