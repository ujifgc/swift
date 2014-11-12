#coding:utf-8
namespace :db do
  desc "backup database"
  task :backup => :environment do
    connection = YAML.load_file( Padrino.root('config/database.yml') )[RACK_ENV]
    dbname = "#{connection['database']}-#{`date +%Y%m%d%H%M%S`.strip}.sql"
    `mysqldump #{connection['database']} --host=#{connection['host']} --user=#{connection['username']} --password=#{connection['password']} --databases > #{Padrino.root}/tmp/#{dbname}`
    p "tmp/#{dbname}"
  end
end
