require 'minitest_helper'

describe 'String' do
  it 'should concat with /' do
    ('foo' / 'bar').must_equal 'foo/bar'
  end
  it 'should squeeze /' do
    ('foo' / '/bar').must_equal 'foo/bar'
  end
end

describe 'Symbol' do
  it 'should concat with /' do
    (:foo / :bar).must_equal 'foo/bar'
  end
end
