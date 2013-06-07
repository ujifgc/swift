#coding: utf-8
require 'minitest_helper'

describe Swift do

  include RenderMethod
  include Padrino::Helpers::RenderHelpers
  include Padrino::Helpers::EngineHelpers
  include Padrino::Helpers::TranslationHelpers
  include Padrino::Helpers::OutputHelpers
  include Padrino::Helpers::TagHelpers 
  
  before do
    @args = { :title => "title", :text => "text"}
    @opts1 = { :kind => :form, :method => "show" }
    @opts2 = { :kind => :inquiry, :method => "post" }
    @swift = {}
    @swift[:slug] =  "slug1/slug2/slug3"\
    
    @page1 = Page.new :title => "Page 1", :path => "/", :parent => nil
    @page2 = Page.new :title => "Page 2", :path => "/page2", :parent => @page1
    @swift[:path_pages] = [@page1, @page2]
  end
  
	it 'should kind-form create' do
		el = element('Forms', @args, @opts1)
		el.must_equal "<dl></dl>"
	end

	it 'should kind-inquiry create' do
		el = element('Forms', @args, @opts2)
		el.must_equal "<dl></dl>"
	end
	
	
end
