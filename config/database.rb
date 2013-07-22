DataMapper::Property::String.length(255)
DataMapper::Logger.new( 'log/sql.log', Padrino.env == :development ? :debug : :error )
DataMapper::Model.append_extensions(Swift::ModelPlugins::ClassMethods)

DataMapper.setup :default, YAML.load_file( Padrino.root('config/database.yml') )[PADRINO_ENV]
