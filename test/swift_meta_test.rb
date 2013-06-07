#coding: utf-8
require 'minitest_helper'

describe Swift do

  include RenderMethod
  include Padrino::Helpers::RenderHelpers
  include Padrino::Helpers::EngineHelpers
  include Padrino::Helpers::TranslationHelpers

  before do
    
  end
  
  it 'should write meta' do
	el = element('Meta')
	el.must_equal "%{placeholder[:meta]}"
  end 


end
