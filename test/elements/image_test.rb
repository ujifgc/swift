#coding: utf-8
require 'elements_helper'

describe Swift do

  before do
#    @image = Image.create :title => "asdfas"
#    @file = Asset.create :title => "asdfas"
  end

  it "should view styles" do
skip
    el = element("Image", @image.id, :title => @image.title, :width => 53, :height => 43)
    el.must_equal "<img alt=\"asdfas\" class=\"Image sized\" height=\"43\" src=\"/images/image_missing.png\" style=\"width:53px;height:43px\" width=\"53\">"
  end

  it "should view link" do
skip
    el = element("Image", @image.id, :title => @image.title, :width => 53, :height => 43, :instance => "link") 
    el.must_equal "<a href=\"/images/image_missing.png\" rel=\"box-image\">asdfas</a>"
  end

  it "should view original" do
skip
    el = element("Image", @image.id, :title => @image.title, :width => 53, :height => 43, :instance => "original")
    el.must_equal "<img alt=\"asdfas\" class=\"Image Image-original sized\" height=\"43\" src=\"/images/image_missing.png\" style=\"width:53px;height:43px\" width=\"53\">"
  end

  it "should view thumbnail-link" do
skip
    el = element("Image", @image.id, :title => @image.title, :width => 53, :height => 43, :instance => "thumbnail-link")
    el.must_equal "<a href=\"/images/image_missing.png\" rel=\"box-image\"><img alt=\"asdfas\" class=\"Image Image-thumbnail-link sized\" height=\"43\" src=\"/images/image_missing.png\" style=\"width:53px;height:43px\" width=\"53\"></a>"
  end

  it "should view thumbnail" do
skip
    el = element("Image", @image.id, :title => @image.title, :width => 53, :height => 43, :instance => "thumbnail") 
    el.must_equal "<img alt=\"asdfas\" class=\"Image Image-thumbnail sized\" height=\"43\" src=\"/images/image_missing.png\" style=\"width:53px;height:43px\" width=\"53\">"
  end

  it "should view default" do
skip
    el = element("Image", @image.id, :title => @image.title, :width => 53, :height => 43) 
    el.must_equal "<img alt=\"asdfas\" class=\"Image sized\" height=\"43\" src=\"/images/image_missing.png\" style=\"width:53px;height:43px\" width=\"53\">"
  end

  it "should throw error" do
skip
    el = element("Image", -1)
    el.must_equal "[Image #-1 missing]"
  end

  after do
  end

end
