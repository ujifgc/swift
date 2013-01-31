source :rubygems

group :development, :test do
  gem 'rake'
  gem 'awesome_print'
end

# Component requirements
gem 'yajl-ruby', :require => 'yajl'
gem 'multi_json'
gem 'tilt', :github => 'ujifgc/tilt', :branch => 'lean-and-mean', :require => ['tilt/mean', 'tilt/haml']
gem 'slim'
gem 'haml', :git => "git://github.com/Asquera/haml.git", :branch => 'standalone-xss-helpers'

# Project requirements
gem 'sinatra-flash', :require => 'sinatra/flash'

# Database requirements
gem 'bcrypt-ruby'
gem 'dm-types', :github => 'ujifgc/dm-types', :branch => 'no-json'
gem 'dm-validations'
gem 'dm-timestamps'
gem 'dm-migrations', :require => false
gem 'dm-constraints'
gem 'dm-aggregates'
gem 'dm-core', '~> 1.2.0' #, :path => '/home/ujif/pro/dm-core'
gem 'dm-mysql-adapter'

gem 'padrino', :github => 'ujifgc/padrino-framework'
#gem 'padrino', :path => '/home/ujif/pro/padrino-framework'

# markdown and content parsing
gem 'redcarpet', :github => 'ujifgc/redcarpet'

# asset compressing
gem 'sinatra-assetpack', :require => 'sinatra/assetpack', :github => 'ujifgc/sinatra-assetpack'
#gem 'sinatra-assetpack', :require => 'sinatra/assetpack', :path => '/home/ujif/pro/sinatra-assetpack'

# file assets
gem 'mini_magick'
gem 'carrierwave', :github => 'ujifgc/carrierwave', :branch => 'multi-json'
gem 'carrierwave-datamapper'

# authorization
gem 'omniauth'
gem 'rack-openid', :require => "rack/openid"
gem 'omniauth-openid'
