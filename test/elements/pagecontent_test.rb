#coding: utf-8
require 'elements_helper'

describe Swift do

  before do
    @page = Page.new :title => "Page 1", :path => "/", :text => "small text info"
  end

  it "should write page content" do
  skip
    el = element("PageContent").strip
    el.must_equal "<p>small text info</p>"
  end

  after do
  end

end
