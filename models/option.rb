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
end

def Option( id )
  value = Option.get( id ).json['value']
  case id
  when :site_title
    value.kind_of?(Hash) ? value[I18n.locale.to_s] : value
  else
    value
  end
rescue NoMethodError
  nil
end
