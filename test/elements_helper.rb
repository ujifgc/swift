require 'minitest_helper'
require 'rack/test'
require 'digest/md5'

class ElementApp < Padrino::Application 
  register Swift::Engine
end

class MiniTest::Spec
  include Rack::Test::Methods
  include Webrat::Methods
  include Webrat::Matchers

  def app
    ElementApp
  end
  
  def element(*args)
    ElementApp.get(Digest::MD5.hexdigest(args.inspect)) do
      element(*args)
    end
    get Digest::MD5.hexdigest(args.inspect)
    last_response.body
  end  
end