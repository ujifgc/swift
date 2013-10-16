#coding: utf-8
require 'elements_helper'

describe Swift do
  before do
  end

  it "should file exists" do
    el = element("File")
    el.must_equal "[Asset # missing]"
  end

  it "should throw error" do
    el = element("File", -1)
    el.must_equal "[Asset #-1 missing]"
  end
end
