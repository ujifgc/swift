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

# instance an environment
ENV['TMP'] = Padrino.root + '/tmp'

require 'nozzle/datamapper'

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

  Padrino.require_dependencies("#{Padrino.root}/lib/dm-*.rb")
  Padrino.require_dependencies("#{Padrino.root}/lib/cyrillic.rb")
  Padrino.require_dependencies("#{Padrino.root}/lib/monkey.rb")

  DataMapper::Model.append_extensions(SwiftDatamapper::ClassMethods)
  DataMapper::Model.append_inclusions(SwiftDatamapper::InstanceMethods)

end

##
# Add your after load hooks here
#
Padrino.after_load do
  DataMapper.finalize
  I18n.reload!  if Padrino.env == :development

  $stat = {}
  sum = { map:0, rss:0 }
  if $memstatMAP
    $memstatMAP.inject({}){ |all,one| $stat[one[0]] = [one[1],$memstatRSS[one[0]]] }
    $stat.to_a.sort_by{ |k,v| v[0] }.each do |k,v|
      next  if v[0] == 0 && v[1] == 0
      sum[:map] += v[0]
      sum[:rss] += v[1]
      puts "MAP: #{v[0].to_s.rjust(7)} KB / RSS: #{v[1].to_s.rjust(7)} KB : #{k}"
    end;nil
    puts " MAP: #{sum[:map].to_s.rjust(7)} KB / RSS: #{sum[:rss].to_s.rjust(7)} KB"
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
