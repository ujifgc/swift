#coding:utf-8

DataMapper.logger = logger
DataMapper::Property::String.length(255)

case Padrino.env
  when :development
    #DataMapper.setup(:default, {:adapter  => "redis", :db => 15 })
    DataMapper.setup(:default, 'mysql://swift:KcRbQA4LhFdLv5Cr@localhost/swift_development')
  when :production
    DataMapper.setup(:default, {:adapter  => "redis", :db => 15 })
  when :test
    DataMapper.setup(:default, {:adapter  => "redis", :db => 15 })
end
