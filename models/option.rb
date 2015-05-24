class Options < Sequel::Model
  plugin :serialization, :json, :json

  attr_accessor :value

  def self.cached_get(id)
    id = id.to_sym
    @cache ||= {}
    return @cache[id] if @cache[id]
    all.each{ |option| @cache[option.id.to_sym] = option.json['value'] }
    @cache[id]
  rescue NoMethodError
    nil
  end

  def self.clear_cache
    @cache.clear
  end

  def after_save
    super
    Options.clear_cache
  end
end

def Option(id)
  value = Options.cached_get(id)
  case id
  when :site_title
    value.kind_of?(Hash) ? value[I18n.locale.to_s] : value
  else
    value
  end
rescue NoMethodError
  nil
end
