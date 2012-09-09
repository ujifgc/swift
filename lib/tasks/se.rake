#coding:utf-8

namespace :se do

  desc "init database for se"
  task :seed => :environment do
    load 'config/dbinit.rb'
  end

end