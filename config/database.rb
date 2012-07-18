#coding:utf-8

#DataMapper.logger = logger
$logger = logger
DataMapper::Logger.new('log/sql.log', :debug)
DataMapper::Property::String.length(255)

case Padrino.env
  when :development
    #DataMapper.setup(:default, {:adapter  => "redis", :db => 15 })
    DataMapper.setup(:default, 'mysql://swift:KcRbQA4LhFdLv5Cr@10.6.7.55/swift_development')
  when :production
    #DataMapper.setup(:default, {:adapter  => "redis", :db => 15 })
    DataMapper.setup(:default, 'mysql://swift:KcRbQA4LhFdLv5Cr@10.6.7.55/swift_development')
  when :test
    #DataMapper.setup(:default, {:adapter  => "redis", :db => 15 })
end
