#coding:utf-8

seeds = YAML::load File.open('config/setup.yml')
seeds.each do |model_name, elements|
  model = model_name.constantize
  elements.each do |slug, attributes|
    elem = model.first_or_new :slug => slug
    if elem.new?
      elem.attributes = attributes.merge( :slug => slug )
      elem.save  or p "error on #{model_name} #{slug}"
    else
      p "skipped existing #{model_name} #{slug}"
    end
  end  
end
