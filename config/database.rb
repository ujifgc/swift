#coding:utf-8

$logger = logger
DataMapper::Logger.new 'log/sql.log', :debug #, :verbose => Padrino.root
DataMapper::Property::String.length(255)

DataMapper.setup :default, YAML.load_file( Padrino.root('config/database.yml') )[PADRINO_ENV]
