module Swift
  module Helpers
    module Locale
      def mk_datetime(date, time)
        DateTime.new date.year, date.month, date.day, time.hour, time.min, time.sec
      end

      private

      def detect_selected_locale
        selected_locale = params[:locale].to_s[0..1]
        if swift.locales.include?(selected_locale)
          selected_locale.to_sym
        else
          detect_session_locale
        end
      end

      def detect_session_locale
        if session[:locale].present? && swift.locales.include?(session[:locale].to_s)
          session[:locale].to_sym
        else
          detect_preferred_locale
        end
      end

      def detect_preferred_locale
        detected_locale = if preferred_languages = request.env['HTTP_ACCEPT_LANGUAGE']
          (parse_http_accept_language(preferred_languages) & swift.locales).first
        end
        detected_locale ||= swift.locales.first
        detected_locale.to_sym
      end

      def parse_http_accept_language( languages )
        languages.gsub(/\s+/,'').split(/,/)
                 .sort_by{ |tags| -(tags.partition(/;/).last.split(/=/)[1]||1).to_f }
                 .map{ |language| language[0..1] }.uniq
      rescue # !!! FIXME detect valid Exceptions
        []
      end
    end
  end
end
