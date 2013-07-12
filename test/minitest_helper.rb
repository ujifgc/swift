ENV['RACK_ENV'] = 'test'
require File.expand_path('../../config/boot.rb', __FILE__)
require 'minitest/autorun'

class MiniTest::Spec
  def swift
    @test_swift ||= OpenStruct.new
  end
end
