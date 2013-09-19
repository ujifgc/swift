module Rack
  # allow params keys to be utf-8 in multipart mode
  module Utils
    class KeySpaceConstrainedParams
      unless instance_methods.map(&:to_s).include?('old_to_params_hash')
        alias_method :old_to_params_hash, :to_params_hash
      end

      def to_params_hash
        Hash[old_to_params_hash.map{ |k,v| [k.dup.force_encoding('utf-8'), v] }]
      end
    end
  end

  # Adds `addr` method to get ip address of a client
  class Request
    def parse_multipart(env)
      Rack::Multipart.parse_multipart(env)
    end

    def addr
      @env['HTTP_X_FORWARDED_FOR'] || @env['REMOTE_ADDR']
    end
  end
end
