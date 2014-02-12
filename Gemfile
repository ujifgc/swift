source 'https://rubygems.org'

# development
group :development, :test do
  gem 'rake'
  gem 'awesome_print'
  gem 'ruby-progressbar'
  gem 'rack-test', ">= 0.5.0"
end

# basic support
gem 'activesupport', :require => 'active_support/core_ext/object/conversions'

# templates and content parsing
gem 'yajl-ruby', :require => 'yajl'
gem 'multi_json'
gem 'slim'
gem 'redcarpet', :github => 'ujifgc/redcarpet', :branch => 'emdash'
gem 'sinatra-flash', :require => 'sinatra/flash'

# padrino framework
padrino_version = '0.12.0'
#padrino_version = { :path => 'padrino-framework' }
#gem 'padrino', padrino_version
gem 'padrino-core', padrino_version
gem 'padrino-gen', padrino_version
gem 'padrino-helpers', padrino_version

# database ORM
gem 'dm-validations'
gem 'dm-timestamps'
gem 'dm-migrations', :require => false
gem 'dm-constraints'
gem 'dm-aggregates'
gem 'dm-core', '~> 1.2.1'
gem 'dm-mysql-adapter'

# file, picture, js, css assets
gem 'nozzle', '~> 0.1.3'
gem 'rack-pipeline', '~> 0.0.5'

# authorization and authentication
gem 'omniauth'
gem 'rack-openid', :require => "rack/openid"
gem 'omniauth-openid'

# mailing
gem 'system_mail', '~> 0.0.3'
