#coding: utf-8
require 'minitest_helper'

describe Swift do

  include RenderMethod
  include Padrino::Helpers::RenderHelpers
  include Padrino::Helpers::EngineHelpers
  include Padrino::Helpers::TranslationHelpers

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
