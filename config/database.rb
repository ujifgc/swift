#coding:utf-8

DataMapper.logger = logger
DataMapper::Property::String.length(255)

case Padrino.env
  when :development then DataMapper.setup(:default, {:adapter  => "redis", :db => 15 })
  when :production  then DataMapper.setup(:default, {:adapter  => "redis", :db => 15 })
  when :test        then DataMapper.setup(:default, {:adapter  => "redis", :db => 15 })
end
