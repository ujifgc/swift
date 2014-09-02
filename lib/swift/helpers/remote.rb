require 'digest/md5'

module Swift
  module Helpers
    module Remote
      def remote_element(name, *args)
        remote_request(remote_api_host, 'element', name, *args)
      end

      def remote_fragment(name, *args)
        remote_request(remote_api_host, name, *args)
      end

      private

      def remote_api_host
        @remote_api_host ||= Option(:api_host)
      end

      def remote_request(host, prefix, *args)
        if respond_to?(:cache)
          cache Digest::MD5.hexdigest([host, prefix, args].inspect), :expires => 5 do
            remote_request_direct(host, prefix, *args)
          end
        else
          remote_request_direct(host, prefix, *args)
        end
      end

      def remote_request_direct(host, prefix, *args)
        opts = Hash === args.last ? args.pop : {}
        uri = URI(File.join(host, prefix, *args.map(&:to_s)))
        uri.query = URI.encode_www_form(opts)
        response = Net::HTTP.get_response(uri)
        if response.is_a?(Net::HTTPSuccess)
          response.body.force_encoding('UTF-8')
          response.body.html_safe
        else
          ''.html_safe
        end
      end
    end
  end
end
