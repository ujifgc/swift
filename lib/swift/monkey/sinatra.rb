require 'rack/showexceptions'
module Sinatra
  class ShowExceptions < Rack::ShowExceptions
    def initialize(app)
      @app      = app
      @template = ERB.new( File.read 'lib/error-500.erb' )
    end
  end
end
