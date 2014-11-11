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
end

def Option(id)
  Option.cached_get(id)
end
