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
  Time::DATE_FORMATS[:default] = '%Y-%m-%d %H:%M'

  Padrino.require_dependencies("#{Padrino.root}/lib/dm-*.rb")
  Padrino.require_dependencies("#{Padrino.root}/lib/sr-*.rb")

  DataMapper::Model.append_extensions(SwiftDatamapper::ClassMethods)
  DataMapper::Model.append_inclusions(SwiftDatamapper::InstanceMethods)

  CarrierWave::SanitizedFile.sanitize_regexp = /[^[:word:]\.\-\+]/

  $renderer = Redcarpet::Render::HTML.new :hard_wrap => true
  $markdown = Redcarpet::Markdown.new $renderer, :autolink => true, :space_after_headers => true, :tables => true, :strikethrough => true
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
