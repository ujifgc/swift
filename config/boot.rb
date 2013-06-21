# Defines our constants
PADRINO_ENV  = ENV["PADRINO_ENV"] ||= ENV["RACK_ENV"] ||= "development"  unless defined?(PADRINO_ENV)
PADRINO_ROOT = File.expand_path('../..', __FILE__) unless defined?(PADRINO_ROOT)

# Load our dependencies
require 'rubygems' unless defined?(Gem)
require 'bundler/setup'
Bundler.require(:default, PADRINO_ENV)

# Enable devel logging
Padrino::Logger::Config[:development] = { :log_level => :devel, :format_datetime => " [%Y-%m-%d %H:%M:%S] ", :stream => :to_file, :colorize_logging => true }
if defined? AwesomePrint
  require 'awesome_print/core_ext/logger'
  Padrino::Logger.send(:include, AwesomePrint::Logger)
end

$LOAD_PATH.unshift Padrino.root('lib')
require 'swift'

# instance an environment
ENV['TMP'] = Padrino.root + '/tmp'

##
# Add your before load hooks here
#
Padrino.before_load do
  
  I18n.load_path += Dir.glob('app/locale/*.yml')
  I18n.load_path += Dir.glob('admin/locale/*.yml')
  I18n.reload!
  I18n.locale = :ru
  
  Time::DATE_FORMATS[:default] = '%Y-%m-%d %H:%M'

  Slim::Engine.set_default_options( {
    :enable_engines => [:ruby, :javascript, :css],
    :format => :html5,
    :use_html_safe => true,
    :generator => Temple::Generators::RailsOutputBuffer,
    :pretty => PADRINO_ENV == "development",
  } )

  DataMapper::Model.append_extensions(Swift::Datamapper::ClassMethods)
  DataMapper::Model.append_inclusions(Swift::Datamapper::InstanceMethods)

  CarrierWave::SanitizedFile.sanitize_regexp = /[^[:word:]\.\-\+]/

end

##
# Add your after load hooks here
#
Padrino.after_load do
  DataMapper.finalize
  I18n.reload!  if Padrino.env == :development

  if $memstat
    stat = $memstat.select{ |k,v| v>0 }.to_a.sort{ |a,b| a[1]<=>b[1] }
    summ = 0
    stat.each do |row|
      summ += row[1]
      puts "#{row[1].to_s.rjust(7)} KB: #{row[0]}"
    end
    puts summ.to_s.rjust(7) + ' KB'
  end

  if $timestat
    stat = $timestat.select{ |k,v| v>0 }.to_a.sort{ |a,b| a[1]<=>b[1] }
    summ = 0
    stat.each do |row|
      summ += row[1]
      #puts "%.6f S: #{row[0]}" % row[1]
    end
    #puts summ.to_s.rjust(7) + ' S'
  end

end

Padrino.load!
