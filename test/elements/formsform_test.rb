#coding: utf-8
require 'elements_helper'

describe Swift do
  before do
    @args = { :title => "title", :text => "text"}
    @opts1 = { :kind => :form, :method => "show" }
    @opts2 = { :kind => :inquiry, :method => "post" }
    @page1 = Page.new :title => "Page 1", :path => "/", :parent => nil
    @page2 = Page.new :title => "Page 2", :path => "/page2", :parent => @page1
    @card = FormsCard.create :title => "test_title", :text => "test_text"
    @swift = { :slug =>  @card[:slug], :path_pages => [@page1, @page2] } 
  end

  it 'should kind-form create' do
#    p @swift
skip
    el = element('FormsForm', @args, @opts1)
    el.must_equal "<dl></dl>"
  end

  after do
    @card.destroy
  end
end
