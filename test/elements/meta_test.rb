#coding: utf-8
require 'elements_helper'

describe Swift do
  before do
  end

  it 'should write meta' do
    skip
    el = element('Meta')
    el.must_equal "%{placeholder[:meta]}"
  end 
end
