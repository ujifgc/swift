$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'minitest/autorun'
require File.expand_path('../../config/boot.rb', __FILE__)
require 'slim'

module RenderMethod
  include Padrino::Helpers::AssetTagHelpers

  def render( engine, template, options={} )
    Slim::Template.new(template, options).render(self)
  end

end
