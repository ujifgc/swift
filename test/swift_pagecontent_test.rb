#coding: utf-8
require 'minitest_helper'

describe Swift do

  include RenderMethod
  include Padrino::Helpers::RenderHelpers
  include Padrino::Helpers::EngineHelpers
  include Padrino::Helpers::TranslationHelpers

  before do
    @page = Page.new :title => "Page 1", :path => "/", :text => "small text info"
  end
  
  it "should write page content" do
    el = element("PageContent").strip
    el.must_equal "<p>small text info</p>"
  end

  after do
  end

end
