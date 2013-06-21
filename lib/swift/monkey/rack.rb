require 'rack/session/abstract/id'
require 'securerandom'

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

  module Session

    class DataMapperSession
      include ::DataMapper::Resource

      storage_names[:default] = 'sessions'

      property :sid, String, :length => 20, :key => true
      property :data, Object
      property :expires_at, Time
    end

    class DataMapper < Abstract::ID

      private

      # generates new session id until it's unique for the store
      def generate_sid
        loop do
          sid = SecureRandom.hex(10)
          break sid  unless DataMapperSession.get(sid)
        end
      end

      # gets a session data from the store by session id OR returns new session id with no data
      def get_session(env, sid)
        @last_session = if sid
          @last_session_object = DataMapperSession.first :sid => sid
          [sid, @last_session_object && @last_session_object.data]
        else
          [generate_sid, nil]
        end
      end

      # puts session data in the store and returns session id if successfull
      def set_session(env, sid, session_data, options)
        session = if @last_session[1] && @last_session[0] == sid && @last_session_object
          @last_session_object
        else
          DataMapperSession.first_or_new:sid => sid
        end
        session.data = session_data
        if options[:expire_after]
          new_at = Time.now + options[:expire_after]
          session.expires_at = new_at  if session.expires_at.nil? || (new_at - session.expires_at > options[:expire_after] / 2)
        else
          session.expires_at = nil
        end
        session.save && session.sid
      end

      # removes session data from the store
      def destroy_session(env, sid, options)
        DataMapperSession.all( :sid => sid ).destroy!
        generate_sid   unless options[:drop]
      end
    end
  end
end
