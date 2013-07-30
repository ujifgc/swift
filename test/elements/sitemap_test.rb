#coding: utf-8
require 'elements_helper'

describe Swift do

  before do
    @page1 = Page.new :title => "Page 1", :path => "/", :parent => nil
    @page2 = Page.new :title => "Page 2", :path => "/page2", :parent => @page1
    @page3 = Page.new :title => "Page 3", :path => "/page2/page3", :parent => @page2
    @page4 = Page.new :title => "Page 4", :path => "page4", :parent => nil
    @page5 = Page.new :title => "Page 5", :path => "page5", :parent => nil
    @page6 = Page.new :title => "Page 6", :path => "page6", :parent => nil
    @page7 = Page.new :title => "Page 7", :path => "page7", :parent => nil
    @swift = {}
    @swift[:path_pages] = [@page1, @page2, @page3, @page4, @page5, @page6, @page7]
    @swift[:path_ids] = [@page1.id, @page2.id, @page3.id, @page4.id, @page5.id, @page6.id, @page7.id]
  end

  it 'should view map' do 
    skip
    el = element('SiteMap')
    el.must_equal ""
  end

end
