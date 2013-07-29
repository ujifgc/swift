#coding:utf-8
require 'minitest_helper'

describe String do
  it 'should concat with /' do
    ('foo' / 'bar').must_equal 'foo/bar'
  end

  it 'should squeeze /' do
    ('foo' / '/bar').must_equal 'foo/bar'
  end

  it 'should slugize a string' do
    'коко лоло ё'.as_slug.must_equal 'koko-lolo-yo'
  end

  it 'should convert cyrillic case' do
    'коко ЛОЛО ё'.case(:up).must_equal 'КОКО ЛОЛО Ё'
    'коко ЛОЛО ё'.case(:lo).must_equal 'коко лоло ё'
    'коко ЛОЛО ё'.case(:cap).must_equal 'Коко лоло ё'
  end
end

describe Symbol do
  it 'should concat with /' do
    (:foo / :bar).must_equal 'foo/bar'
  end
end

describe NilClass do
  it 'should appear empty' do
    nil.any?.must_equal nil
  end
end

describe OpenStruct do
  it 'should behave like Hash' do
    o = OpenStruct.new
    o[:foo].must_equal nil
    (o[:foo] = 'bar').must_equal 'bar'
    o[:foo].must_equal 'bar'
  end
end
