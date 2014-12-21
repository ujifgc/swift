module Swift
  module Helpers
    module Init
      def init_page
        path = normalize_path swift.path
        page = find_page_or_module path
        redirect_if_blank page
        merge_default_params page
        init_path_pages page
        @page = page
      end

      def init_error( errno )
        init_path_pages
        @page = Page.first :path => "/error/#{errno}"
        @page ||= Page.new :title => "Error #{errno}", :text => "page /error/#{errno} not found"
      end

      def init_swift
        return  if @_inited
        init_folders
        init_media
        init_locale
        init_http
        @_inited = true
      end

      private

      def find_page_or_module( path )
        page = Page.first( :conditions => [ "? LIKE IF(is_module,CONCAT(path,'%'),path)", path ], :order => :path.desc )
        # FIXME possible SQLite fix, test against MySQL:
        #page = Page.first( :conditions => [ "? LIKE CASE WHEN is_module THEN path||'%' ELSE path END", path ], :order => :path.desc )
        swift.fragment = (page = detect_module_slug(page, path)) ? page.fragment_id : 'error'
        page
      end

      def normalize_path( path )
        path.squeeze! '/'
        path[1] ? path.chomp('/') : path
      end

      def redirect_if_blank( page )
        if page && page.parent_id && page.fragment_id == 'page' && page.text.blank? && !page.is_module
          first_child = page.children.first( :order => :position )
          redirect first_child.path  if first_child
        end
      end

      def merge_default_params( page )
        params.reverse_merge! Rack::Utils.parse_query(page.params)  if page && page.params.present?
      end

      def detect_module_slug( page, path )
        if page && page.is_module
          swift.module_root = page.path
          swift.slug = case path[page.path.length]
          when '/'
            path[(page.path.length+1)..-1]
          when nil
            ''
          else
            page = nil
          end
        end
        page
      end

      def init_path_pages( page = Page.root )
        while page
          swift.path_pages.unshift page
          swift.path_ids.unshift page.id
          page = page.parent
        end
      end

      def init_http
        swift.http_method = request.env['REQUEST_METHOD']
        swift.host = request.env['SERVER_NAME']
        swift.request = request.env['REQUEST_URI']
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

      def init_locale
        swift.locales = Option(:locales) || %w(ru en)
        swift.locale = params[:locale] ? detect_selected_locale : detect_session_locale
        session[:locale] = swift.locale
        I18n.available_locales = swift.locales
        I18n.locale = swift.locale
      end
    end
  end
end
