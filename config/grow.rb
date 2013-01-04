# load yml to database [Code]
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

# load yml to database [Option]
seeds = YAML::load File.open('config/setup-options.yml')
seeds.each do |model_name, elements|
  model = model_name.constantize
  elements.each do |id, attributes|
    elem = model.first_or_new :id => id
    if elem.new?
      elem.attributes = attributes.merge( :id => id )
      elem.save  or p "error on #{model_name} #{id}"
    else
      p "skipped existing #{model_name} #{id}"
    end
  end  
end

# load elements do db
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
