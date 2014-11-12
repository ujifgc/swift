#coding:utf-8
namespace :se do
  desc "init database for se"
  task :setup => :environment do
    DataMapper.auto_upgrade!
    load 'config/setup.rb'
  end

  desc "grow database for se"
  task :grow => :environment do
    DataMapper.auto_upgrade!
    load 'config/grow.rb'
  end
end
