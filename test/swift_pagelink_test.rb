#coding: utf-8
require 'minitest_helper'

describe Swift do

  include RenderMethod
  include Padrino::Helpers::RenderHelpers
  include Padrino::Helpers::EngineHelpers
  include Padrino::Helpers::TranslationHelpers

  before do
    @page1 = Page.new :title => "Page 1", :path => "/", :parent => nil
  end
  
  it "should link created" do
    el = element("PageLink", @page1)
    el.must_equal "[Page ##{@args[0]} missing]"
  end

  it "should throw error" do
    el = element("PageLink")
    el.must_equal "[Page # missing]"
  end

end
