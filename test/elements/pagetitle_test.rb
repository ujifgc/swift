#coding: utf-8
require 'elements_helper'

describe Swift do

  before do
    @page = Page.new :title => "Page 1", :path => "/", :text => "small text info"
  end

  it "should write page title" do
skip
    el = element("PageTitle").strip
    el.must_equal "<title>Новый сайт — %{placeholder[:html_title]}</title>"
  end

  it "should throw error" do
  skip
    el = element("PageContent").strip
    el.must_equal "<p>small text info</p>"
  end

end
