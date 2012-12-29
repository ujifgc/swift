#coding:utf-8

namespace :se do

  desc "init database for se"
  task :setup => :environment do
    load 'config/setup.rb'
  end

end