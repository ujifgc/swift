#coding:utf-8

namespace :se do

  desc "init database for se"
  task :setup => :environment do
    load 'config/setup.rb'

    elements = YAML.load_file 'config/setup-elements.yml'
    Dir.glob( Swift.root / 'views/elements/*' ) do |dir|
      slug = File.basename(dir)
      elem = Element.first_or_new :id => slug
      if elem.new?
        elem.title = elements['Element'][slug]['title']  rescue slug
        elem.save  or p "error on Element #{slug}"
      else
        p "skipped existing Element #{slug}"
      end
    end
  end

end