require 'minitest_helper'

describe Padrino::Helpers::EngineHelpers do

  include Padrino::Helpers::EngineHelpers

  it "url_replace should work on hash" do
    url_replace( '/', :a => 2 ).must_equal '/?a=2'
    url_replace( '/news', { b: nil } ).must_equal '/news'
    url_replace( '/news?b=2', { b: nil } ).must_equal '/news'
    url_replace( '/news?b=2', { b: 3 } ).must_equal '/news?b=3'
  end

  it "url_replace should work on string" do
    url_replace( '/news?a=b', '/bar' ).must_equal '/bar?a=b'
  end

  it "url_replace should work on string and hash" do
    url_replace( '/news/udnii', '/news/important', {} ).must_equal '/news/important'
    url_replace( '/news?a=b&c=d', '/bar', c: nil ).must_equal '/bar?a=b'
    url_replace( '/news?a=b&c=d', '/bar', a: nil ).must_equal '/bar?c=d'
    url_replace( '/news?a=b&c=d', '/bar', c: nil, a: nil ).must_equal '/bar'
  end

end
