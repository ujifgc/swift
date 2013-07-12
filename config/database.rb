DataMapper::Logger.new( 'log/sql.log', Padrino.env == :development ? :debug : :error )
DataMapper::Property::String.length(255)
DataMapper.setup :default, YAML.load_file( Padrino.root('config/database.yml') )[PADRINO_ENV]
