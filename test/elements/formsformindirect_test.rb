#coding: utf-8
require 'elements_helper'

describe Swift do
  before do
    @card = FormsCard.create :title => "test_title", :text => "test_text"
    @swift = { :slug =>  @card[:slug]} 
  end
  
  it 'shiuld POST method run' do
    skip
    @swift[:method] = 'POST/i'
    el = element('FormsFormIndirect')
    el.must_equal ""
  end
	
  it 'shiuld GET method run' do
    skip
    @swift[:method] = 'GET/i'
    el = element('FormsFormIndirect')
    el.must_equal ""
  end
end
