#coding: utf-8
require 'elements_helper'

describe Swift do

  before do
    @page1 = Page.new :title => "Page 1", :path => "/", :parent => nil
  end

  it "should link created" do
  skip
    el = element("PageLink", @page1)
    el.must_equal "[Page ##{@args[0]} missing]"
  end

  it "should throw error" do
  skip
    el = element("PageLink")
    el.must_equal "[Page # missing]"
  end

end
