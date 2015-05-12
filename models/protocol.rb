require 'zlib'
require 'tempfile'

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

  def self.restore(type, id, at)
    model = type.constantize
    instance = model.get(id) || model.new
    trace(type, id, at).each do |step|
      instance.attributes = step.object
    end
    instance
  end

  def self.full_trace(type, id)
    all(:object_type => type, :object_id => id, :order => :time.desc).inject({}) do |hash, object|
      hash[object.time] = object
      hash      
    end
  end

  @full_trace = {}

  def self.trace_at(type, id, at)
    traced = @full_trace[[type, id]] ||= full_trace(type, id)
    traced.select{ |key,_| key >= at }.values
  end

  def self.trace(type, id, at)
    all(:object_type => type, :object_id => id, :time.gte => at, :order => :time.desc)
  end

  def self.track_attributes(*attributes)
    all(:order => :time.desc).select do |step|
      good = false
      json = step.object
      Array(attributes).each do |key|
        if json[key]
          good = true
          break
        end
      end
      good
    end
  end

  # instance helpers
  def object
    JSON.parse data
  rescue
    { :json => data }
  end

  def restore(at = nil)
    instance = latest || object_type.constantize.new
    trace(at).each do |step|
      instance.attributes = step.object
    end
    instance
  end

  def now
    restore(time + 1.second)
  end

  def latest
    object_type.constantize.get(object_id)
  end

  def trace(at = nil)
    self.class.trace_at(object_type, object_id, at || time)
  end

  def data
    @inflated_data ||= Zlib.inflate( attribute_get(:data) ).force_encoding( Encoding.default_external )
  rescue
    attribute_get(:data)
  end

  def data=(value)
    attribute_set( :data, Zlib.deflate( value.force_encoding('binary') ) )
  end

  def diff(field=:text)
    original = restore
    modified = now
    original_file = Tempfile.new('original_diff')
    original_file.write(original[field]+"\r\n")
    original_file.close
    modified_file = Tempfile.new('modified_diff')
    modified_file.write(modified[field]+"\r\n")
    modified_file.close
    result = `diff -u '#{original_file.path}' '#{modified_file.path}'`
    [original_file, modified_file].each(&:unlink)
    Array(result.lines[2..-1]).join
  end
end
