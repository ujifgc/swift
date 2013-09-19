require 'rack/session/abstract/id'

Serializer = YAML

module Rack
  module Session
    class File < Abstract::ID
      def initialize( *args )
        super( *args )
        @temp_dir = 'tmp/sessions'
      end

      private

      def path( sid )
        Dir.mkdir @temp_dir  unless ::File.directory? @temp_dir
        ::File.join(@temp_dir, sid)
      end

      # generates new session id until it's unique for the store
      def new_sid
        loop do
          sid = SecureRandom.hex(10)
          break sid  unless ::File.exists?( path sid )
        end
      end

      def now_after?(expiry)
        Time.now.to_i >= expiry.to_i && expiry.to_i > 0
      end

      def get_expiry(options)
        options[:expire_after] ? (Time.now + options[:expire_after]).to_i : 0
      end

      # gets a session data from the store by session id OR returns new session id with no data
      def get_session(env, sid)
        @data = nil
        @sid = if sid && ::File.file?( file = path(sid) )
          @data, expiry = *Serializer.load(::File.read file)
          if now_after? expiry
            ::File.unlink( file ) rescue nil
            @data = nil
            new_sid
          else
            sid
          end
        else
          new_sid
        end
        [ @sid, @data ]
      rescue Psych::SyntaxError
        ::File.unlink file
        retry
      end

      # puts session data in the store and returns session id
      def set_session(env, sid, data, options)
        if @data != data || @sid != sid
          ::File.write path(sid), Serializer.dump( [ data, get_expiry(options) ] )
        end
        sid
      end

      # removes session data from the store
      def destroy_session(env, sid, options)
        ::File.unlink(path sid) rescue nil
        new_sid  unless options[:drop]
      end
    end
  end
end
