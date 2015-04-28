module MultiJson
  module_function

  def decode(*args)
    warn 'MultiJson in no longer used. Please use ActiveSupport::JSON.decode'
    ActiveSupport::JSON.decode(*args)
  end

  def encode(*args)
    warn 'MultiJson in no longer used. Please use ActiveSupport::JSON.encode'
    ActiveSupport::JSON.encode(*args)
  end
end
