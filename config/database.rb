#coding:utf-8

$logger = logger
DataMapper::Logger.new('log/sql.log', :debug)
DataMapper::Property::String.length(255)

File.open('config/database.yml') do |db|
  DataMapper.setup :default, YAML::load(db)[Padrino.env.to_s]
end
