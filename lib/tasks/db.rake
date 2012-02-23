#coding:utf-8

namespace :db do

  desc "backup database"
  task :backup => :environment do
    `mysqldump swift_development -u swift --password=KcRbQA4LhFdLv5Cr --databases > #{Padrino.root}/db/db.sql`
  end

end