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

  desc "generate reditect map config/remap.yml from Protocol"
  task :remap => :environment do
    data = {}
    ['Page'].each do |model|
      model_data = {}
      Protocol.all(:object_type => model).track_attributes('slug','parent_id').each do |step|
        if step.latest
          restored_path = step.restore.restore_path(step.time)
          latest_path = step.latest.path
          model_data[restored_path] ||= latest_path
          model_data.delete(restored_path) if restored_path == latest_path
        end
      end
      data[model] = model_data
    end
    File.write('config/remap.yml', data.to_yaml)
  end
end
