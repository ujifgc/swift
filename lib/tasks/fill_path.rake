#coding:utf-8
namespace :set do
  desc "init database for se"
  task :paths => :environment do
    folders = Folder.all
    folders.each do |folder|
      p folder.slug
      folder.path = folder.slug
      folder.save
      p "success"
    end
  end
end
