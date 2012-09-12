#coding:utf-8

namespace :se do

  desc "init database for se"
  task :setup => :environment do
    load 'config/setup.rb'

    elements = YAML::load File.open('config/setup-elements.yml')
    Dir.glob( Swift.root / 'views/elements/*' ) do |dir|
      slug = File.basename(dir)
      elem = Element.first_or_new :id => slug
      elem.title = elements['Element'][slug]['title']
      p elem.save
    end
  end

end