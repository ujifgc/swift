class Option
  include DataMapper::Resource
  
  property :id, String, :length => 20, :key => true
  property :title, String
  property :json, Json, :lazy => false, :default => {}
  attr_accessor :value

  before :valid? do
    self.json = { 'value' => value }  if value
  end

  def get_value
    json['value']
  end

  def self.cached_get(id)
    id = id.to_sym
    @cache ||= {}
    return @cache[id] if @cache[id]
    all(:fields => [:id, json]).each{ |option| @cache[option.id.to_sym] = option.json['value'] }
    @cache[id]
  rescue NoMethodError
    nil
  end

  def self.clear_cache
    @cache.clear
  end

  after :save do
    Option.clear_cache
  end
end

def Option(id)
  value = Option.cached_get(id)
  case id
  when :site_title
    value.kind_of?(Hash) ? value[I18n.locale.to_s] : value
  else
    value
  end
rescue NoMethodError
  nil
end
