#coding: utf-8
require 'minitest_helper'

describe Swift do

  include RenderMethod
  include Padrino::Helpers::RenderHelpers
  include Padrino::Helpers::EngineHelpers
  include Padrino::Helpers::TranslationHelpers

  before do
    @page1 = Page.new :title => "Page 1", :path => "/", :parent => nil
    @page2 = Page.new :title => "Page 2", :path => "/page2", :parent => @page1
    @swift = {}
    @swift[:path_pages] = [@page1, @page2]
  end

  it "should not nil page" do
    el = element("Breadcrumbs", :spacer => ">")
    el.must_equal "<div class=\"breadcrumbs\"><a href=\"/\">Главная</a>&gt;<a href=\"/page2\">Page 2</a></div>"
  end


end
