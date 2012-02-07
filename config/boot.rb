# Defines our constants
PADRINO_ENV  = ENV["PADRINO_ENV"] ||= ENV["RACK_ENV"] ||= "development"  unless defined?(PADRINO_ENV)
PADRINO_ROOT = File.expand_path('../..', __FILE__) unless defined?(PADRINO_ROOT)

# Load our dependencies
require 'rubygems' unless defined?(Gem)
require 'bundler/setup'
Bundler.require(:default, PADRINO_ENV)

##
# Enable devel logging
#
Padrino::Logger::Config[:development] = { :log_level => :devel, :stream => :to_file }


##
# Add your before load hooks here
#
Padrino.before_load do
  I18n.locale = :ru
  Padrino.require_dependencies("#{Padrino.root}/lib/dm-*.rb")
  Padrino.require_dependencies("#{Padrino.root}/lib/sr-*.rb")
  DataMapper::Model.append_extensions(SwiftDatamapper::ClassMethods)
  DataMapper::Model.append_inclusions(SwiftDatamapper::InstanceMethods)
  $markdown = Redcarpet::Markdown.new Redcarpet::Render::HTML, :autolink => true, :space_after_headers => true, :tables => true, :strikethrough => true
end

##
# Add your after load hooks here
#
Padrino.after_load do
  DataMapper.finalize
  #I18n.reload!  if Padrino.env == :development
end

Padrino.load!
