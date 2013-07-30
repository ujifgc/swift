require 'zlib'

class Protocol
  include DataMapper::Resource

  IGNORED_PROPERTIES = [:updated_at]

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
    data = args[:data] || args[verb].attributes
    return  unless data.any?
    p = Protocol.create( {
      :subject => Account.current,
      :verb => verb,
      :time => object.updated_at,
      :object_id => object.id,
      :object_type => object.class.name,
      :data => data.to_json
    } )
    if Protocol.size > Option(:max_protocol_size).to_i
      #steps = Protocol.all( :object_id => object.id, :object_type => object.class.name, :order => :time.asc )
      # !!! FIXME implement garbage collection for protocol
    end
  end

  def self.size
    repository(:default).adapter.select("SHOW TABLE STATUS LIKE 'protocols'").first[:data_length].to_i
  end

  def self.biggest
    row = repository(:default).adapter.select("SELECT object_id, object_type, sum(CHAR_LENGTH(data)) sz FROM `protocols` group by object_id, object_type order by sz").last
    row ? { :object_id => row.object_id, :object_type => row.object_type } : nil
  end

  def self.longest
    row = repository(:default).adapter.select("SELECT object_id, object_type, count(CHAR_LENGTH(data)) co FROM `protocols` group by object_id, object_type order by co").last
    row ? { :object_id => row.object_id, :object_type => row.object_type } : nil
  end

  def self.for( subject, object = nil, opts = {} )
    range = case opts[:range]
    when Range
      opts[:range]
    when Fixnum
      (DateTime.now - opts[:range])..DateTime.now
    else
      nil
    end
    filter = { :order => :time.desc }
    filter[:time] = range  if range      
    case subject
    when Account
      filter[:subject_id] = subject.id
      if object
        filter[:object_id] = object.id
        filter[:object_type] = object.class.name
      end
    else
      filter[:object_id] = subject.id
      filter[:object_type] = subject.class.name
    end
    all filter
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
    attribute_get(:data)
  end

  def data=(value)
    attribute_set( :data, Zlib.deflate( value.force_encoding('binary') ) )
  end
end
