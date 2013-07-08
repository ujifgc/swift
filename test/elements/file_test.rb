#coding: utf-8
require 'elements_helper'

describe Swift do

  before do
  end

  it "should file exists" do
  skip
    el = element("File")
    el.must_equal "[Asset # missing]"
  end

  it "should throw error" do
  skip
    el = element("File", -1)
    el.must_equal "[Asset #-1 missing]"
  end
  
  it "!" do
  end
  

end
