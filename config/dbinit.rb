#coding:utf-8

seeds = YAML::load File.open('config/dbinit.yml')
seeds.each do |model_name, elements|
  model = model_name.constantize
  elements.each do |slug, attributes|
    model.first_or_create attributes.merge( :slug => slug )
  end  
end
