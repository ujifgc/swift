# configure environment
RACK_ENV = ENV['RACK_ENV'] ||= 'development'  unless defined?(RACK_ENV)
PADRINO_ROOT = File.expand_path('../..', __FILE__)  unless defined?(PADRINO_ROOT)
ENV['TMP'] = File.join(PADRINO_ROOT, 'tmp')

module Markdown; end

# load bundle
require 'rubygems' unless defined?(Gem)
require 'bundler/setup'
Bundler.require(:default, RACK_ENV)

# configure logging
Padrino::Logger::Config[:development] = { :log_level => :devel, :format_datetime => " [%Y-%m-%d %H:%M:%S] ", :stream => :to_file, :colorize_logging => true }
if defined? AwesomePrint
  require 'awesome_print/core_ext/logger'
  Padrino::Logger.send(:include, AwesomePrint::Logger)
end

# allow requiring swift stack from lib and require it
$LOAD_PATH.unshift Padrino.root('../base/lib')
require 'swift'

# plug in external gems: nozzle for image processing, rack-pipeline for js/css combining
require 'nozzle/datamapper'
require 'rack-pipeline/sinatra'

# openid authentication
require 'omniauth-openid'
require 'openid/store/filesystem'
require 'active_support/json'
require 'active_support/core_ext/object/conversions'
require 'active_support/core_ext/object/json'

ActiveSupport::JSON::Encoding.escape_html_entities_in_json = false

Padrino.before_load do
  I18n.locale = :ru
  I18n.available_locales = [:ru]

  Time::DATE_FORMATS[:default] = '%Y-%m-%d %H:%M'

  Slim::Engine.set_options( {
    :enable_engines => [:ruby, :javascript, :css],
    :format => :html,
    :use_html_safe => true,
    :pretty => true,
  } )
end

Padrino.after_load do
  DataMapper.finalize
  Nozzle.finalize
end

Padrino.load!
