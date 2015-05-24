DataMapper::Property::String.length(255)
DataMapper::Logger.new('log/sql.log', Padrino.env == :development ? :debug : :error)
DataMapper::Model.append_extensions(Swift::ModelPlugins::ClassMethods)

database = YAML.load_file(Padrino.root('config/database.yml'))[RACK_ENV]

DataMapper.setup(:default, database)

#DB = Sequel.connect(database) #.merge(:adapter => 'swift', :db_type => 'mysql'))
DB = Sequel.connect(database.merge(:adapter => 'mysql', :charset => 'utf8'))
DB.loggers << Logger.new('log/sequel.log')
DB.loggers << Logger.new($stdout)

#ap GC.stat
ap `pmap #{Process.pid} | tail -1` #[10..40].strip.to_i
ap `pmap -x #{Process.pid} | tail -1` #[28..40].strip.to_i
