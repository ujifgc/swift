module Swift
  module Helpers
    module Error
      def report_error( error, subsystem = 'system', fallback = nil )
        @_out_buf ||= ''.html_safe # !!! FIXME this might be fixed at tilt 1.3.8+
        if Padrino.env == :production
          messages = ''
          [ "Swift caught a runtime error at #{subsystem}",
            "Fallback for development was #{fallback||'empty'}, production displayed empty string.",
            error.message,
          ].each do |message|
            logger.error message
            messages << message + "\r\n"
          end
          error.backtrace.reject{ |e| e.match /phusion_passenger/ }.each do |step|
            logger << step
            messages << step + "\r\n"
          end
          @swift[:error_messages] ||= []
          @swift[:error_messages] << messages
          ''
        else
          fallback || raise
        end
      end
    end
  end
end
