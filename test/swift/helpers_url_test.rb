require 'minitest_helper'

MiniTest::Spec.send :include, Swift::Helpers::Url

describe 'url_replace' do
  it "should work on hash" do
    url_replace( '/', :a => 2 ).must_equal '/?a=2'
    url_replace( '/news', { b: nil } ).must_equal '/news'
    url_replace( '/news?b=2', { b: nil } ).must_equal '/news'
    url_replace( '/news?b=2', { b: 3 } ).must_equal '/news?b=3'
  end

  it "should work on string" do
    url_replace( '/news?a=b', '/bar' ).must_equal '/bar?a=b'
  end

  it "should work on string and hash" do
    url_replace( '/news/udnii', '/news/important', {} ).must_equal '/news/important'
    url_replace( '/news?a=b&c=d', '/bar', c: nil ).must_equal '/bar?a=b'
    url_replace( '/news?a=b&c=d', '/bar', a: nil ).must_equal '/bar?c=d'
    url_replace( '/news?a=b&c=d', '/bar', c: nil, a: nil ).must_equal '/bar'
  end
end

describe 'se_url' do
  it 'should make NewsArticle link' do
    se_url(NewsArticle.new(:slug => 'test')).must_equal "/news/show/test"
    se_url(NewsArticle.new(:slug => 'test'), 'kill').must_equal "/news/kill/test"
  end

  it 'should make FormsCard link' do
    se_url(FormsCard.new(:slug => 'test')).must_equal "/forms/show/test"
    se_url(FormsCard.new(:slug => 'test'), 'kill').must_equal "/forms/kill/test"
  end

  it 'should make Page link' do
    se_url(Page.new :path => '/r1/r2/r3').must_equal "/r1/r2/r3"
  end

  it 'should make a link in a module' do
    swift.module_root = '/foo'
    object = OpenStruct.new :slug => 'bar'
    se_url(object).must_equal '/foo/show/bar'
    se_url(object, :kill).must_equal '/foo/kill/bar'
  end

  it 'should fallback to root' do
    swift.module_root = nil
    object = OpenStruct.new :slug => 'bar'
    se_url(object).must_equal '/'
  end
end
