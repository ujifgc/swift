#coding:utf-8
require 'zlib'

class Protocol
  include DataMapper::Resource

  property :id, Serial
  belongs_to :subject,    'Account',  :required => true
  property :verb,          String,    :required => true
  property :time,          DateTime,  :required => true
  property :object_id,     Integer,   :required => true
  property :object_type,   String,    :required => true
  property :data,          Binary,    :length  => 65535

  # relations

  # hookers
  def self.log(args)
    verb = args.keys.first
    object = args[verb]
    p = Protocol.create( {
      :subject => object.updated_by,
      :verb => verb,
      :time => object.updated_at,
      :object_id => object.id,
      :object_type => object.class.name,
      :data => object.attributes.to_json
    } )
    throw p.errors  if p.errors.any?
  end

  # instance helpers
  def object
    JSON.parse data
  rescue
    {}
  end

  def data
    Zlib.inflate( attribute_get(:data) ).force_encoding( Encoding.default_external )
  rescue
    "{}"
  end

  def data=(value)
    attribute_set( :data, Zlib.deflate( value.force_encoding('binary') ) )
  end

end
