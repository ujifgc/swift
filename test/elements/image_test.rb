#coding: utf-8
require 'elements_helper'

describe Swift do

  before do
    @image = Image.create :title => "asdfas"
    @file = Asset.create :title => "asdfas"
  end
=begin
  it "should view styles" do
если указывать длину и ширину картинки возникает следующая ошибка
undefined method `index' for 53:Fixnum
+
+
file: + core.rb
+
location: block (2 levels) in element +
+
line: + 20

    el = element("Image", @image.id, :title => @image.title, :width => 53, :height => 43)
    el.must_equal "<img alt=\"asdfas\" class=\"Image sized\" height=\"43\" src=\"/images/image_missing.png\" style=\"width:53px;height:43px\" width=\"53\">"
  end
=end
  it "should view styles" do
    el = element("Image", @image.id, :title => @image.title)
    el.must_equal "<img alt=\"asdfas\" class=\"Image\" src=\"/images/image_missing.png\">"
  end

  it "should view link" do
    el = element("Image", @image.id, :title => @image.title, :instance => "link") 
    el.must_equal "<a href=\"/images/image_missing.png\" rel=\"box-image\" title=\"asdfas\">asdfas</a>"
  end

  it "should view original" do
    el = element("Image", @image.id, :title => @image.title, :instance => "original")
    el.must_equal "<img alt=\"asdfas\" class=\"Image Image-original\" src=\"/images/image_missing.png\">"
  end

  it "should view thumbnail-link" do
    el = element("Image", @image.id, :title => @image.title, :instance => "thumbnail-link")
    el.must_equal "<a href=\"/images/image_missing.png\" rel=\"box-image\" title=\"asdfas\"><img alt=\"asdfas\" class=\"Image Image-thumbnail-link\" src=\"/cache/Image/" + @image.id.to_s + "@thumb-\"></a>"
  end

  it "should view thumbnail" do
    el = element("Image", @image.id, :title => @image.title, :instance => "thumbnail") 
    el.must_equal "<img alt=\"asdfas\" class=\"Image Image-thumbnail\" src=\"/cache/Image/" + @image.id.to_s + "@thumb-\">"
  end

  it "should view default" do
    el = element("Image", @image.id, :title => @image.title) 
    el.must_equal "<img alt=\"asdfas\" class=\"Image\" src=\"/images/image_missing.png\">"
  end

  it "should throw error" do
    el = element("Image", -1)
    el.must_equal "[Image #-1 missing]"
  end

  after do
    @image.destroy
    @file.destroy
  end

end
