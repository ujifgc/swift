class CatNode
  include DataMapper::Resource

  property :id,       Serial

  property :title,    String, :required => true, :length => 4095
  property :text,     Text

  sluggable! :unique_index => false
  timestamps!
  userstamps!
  loggable!
  publishable!
  bondable!
  amorphous!
  recursive!
  metable!
  datatables!( :id, :title, :cat_card,
    :format => { :cat_card => { :code => 'o.cat_card && o.cat_card.title' } }
  )

  property :sort1, String
  property :sort2, String
  property :sort3, String

  # relations
  belongs_to :cat_card, :required => true

  # hookers
  before :valid? do
    if cat_card && cat_card.sort_cache.kind_of?(Hash)
      cat_card.sort_cache.each do |cache_field, json_field|
        if cat_card[json_field][0] == 'number'
          self.send "#{cache_field}=", json[json_field].to_i.to_s.rjust(16,'0').sub(/#{json[json_field].to_i.to_s}$/, json[json_field].to_s)[0..254]
        else
          self.send("#{cache_field}=", (json[json_field] || send(json_field))[0..254])
        end
      end
    end
  end

  # validations
  validates_with_block :json do
    @json_errors = {}
    cat_card.json.each do |key, type|
      if type[0].to_sym == :json && json[key].kind_of?(String)
        begin
          json[key] = ActiveSupport::JSON.decode(json[key])
        rescue JSON::ParserError => e
          @json_errors[key] = e.message
        end
      end
    end
    if @json_errors.any?
      [false, I18n.t('datamapper.errors.messages.json_error')]
    else
      true
    end
  end

  # instance helpers

  # class helpers
  def self.filter_by( object )
    case object.class.name
    when 'CatCard'
      all :cat_card_id => object.id
    when 'CatGroup'
      filter_strings = []
      filter_regexes = []
      while object
        object.json.each do |key,value|
          filter_strings << 'json REGEXP ?'
          filter_regexes << /\"#{key}\"\:\"#{value}\"/
        end
        object = object.parent
      end
      filter = [filter_strings.join(' AND ')]
      filter += filter_regexes

      if filter[0].length > 0
        all :conditions => filter
      else
        all
      end
    else
      all
    end
  end
end
