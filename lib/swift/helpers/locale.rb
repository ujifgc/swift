module Swift
  module Helpers
    module Locale
      def mk_datetime(date, time)
        DateTime.new date.year, date.month, date.day, time.hour, time.min, time.sec
      end

      private

      def detect_locale
        detect_domain_locale
      end

      def detect_domain_locale
        hostname = request.env['HTTP_HOST']
        if hostname =~ /^(#{Regexp.union(swift.locales)})\.(.+)$/
          $1
        else
          redirect "#{request.env['rack.url_scheme']}://#{detect_preferred_locale}.#{hostname}#{request.env['REQUEST_URI']}"
        end
      end

      def detect_prefix_locale
        fail 'not implemented, needs total rework of url building'
        pattern = /^\/?(#{Regexp.union(swift.locales)})(\/.+)$/
        if request.path_info =~ pattern
          request.path_info = $2
          locale = $1
        else
          redirect "/#{detect_preferred_locale}#{request.env['REQUEST_URI']}"
        end
      end

      def detect_selected_locale
        warn '#detect_selected_locale is deprecated'
        selected_locale = params[:locale]
        if swift.locales.include?(selected_locale)
          selected_locale
        else
          detect_session_locale
        end
      end

      def detect_session_locale
        warn '#detect_session_locale is deprecated'
        if session[:locale].present? && swift.locales.include?(session[:locale])
          session[:locale]
        else
          detect_preferred_locale
        end
      end

      def detect_preferred_locale
        detected_locale = if preferred_languages = request.env['HTTP_ACCEPT_LANGUAGE']
          (parse_http_accept_language(preferred_languages) & swift.locales).first
        end
        detected_locale ||= swift.locales.first
        detected_locale || fail('failed to detect any locale')
      end

      def parse_http_accept_language( languages )
        languages.gsub(/\s+/,'').split(/,/)
                 .sort_by{ |tags| -(tags.partition(/;/).last.split(/=/)[1]||1).to_f }
                 .map{ |language| language.split('-').last }.uniq
      rescue # !!! FIXME detect valid Exceptions
        []
      end
    end
  end
end
