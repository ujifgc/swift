source 'https://rubygems.org'

# development
group :development, :test do
  gem 'rake'
  gem 'awesome_print'
  gem 'ruby-progressbar'
  gem 'rack-test', ">= 0.5.0"
end

# basic support
gem 'activesupport', '~> 4.1.0', :require => false

# templates and content parsing
gem 'slim'
gem 'tight-redcarpet', '~> 3'
gem 'sinatra-flash', :require => 'sinatra/flash'

# padrino framework
padrino_version = '0.12.2'
#padrino_version = { :path => '/home/ujif/pro/padrino-framework' }
gem 'padrino-core', padrino_version
gem 'padrino-helpers', padrino_version
gem 'padrino-auth', '~> 0.0.12'

# database ORM
gem 'dm-validations'
gem 'dm-timestamps'
gem 'dm-migrations', :require => false
gem 'dm-constraints'
gem 'dm-aggregates'
gem 'dm-core', '~> 1.2.1'
gem 'dm-mysql-adapter'

# file, picture, js, css assets
gem 'nozzle', '~> 0.1.6'
gem 'rack-pipeline', '~> 0.0.9'

# authorization and authentication
gem 'omniauth'
gem 'rack-openid', :require => "rack/openid"
gem 'omniauth-openid'

# mailing
gem 'system_mail', '~> 0.0.3'
