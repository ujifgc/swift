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
  Option.get( id ).json['value']  rescue nil
end
