class Option
  include DataMapper::Resource
  
  property :id, String, :length => 20, :key => true
  property :title, String
  property :text, Text, :lazy => false

  def self.get( id )
    obj = super( id )  or return nil
    return DateTime.parse(obj.text)  if obj.text.match(/\d\d\d\d\-\d\d\-\d\d/)
    return obj.text.to_i  if obj.text.match(/^[\+\-\d]+$/)
    obj.text
  end

end

def Option( id )
  Option.get id
end
