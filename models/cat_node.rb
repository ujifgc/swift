class CatNode
  include DataMapper::Resource

  property :id,       Serial

  property :title,    String, :required => true
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

  # relations
  belongs_to :cat_card, :required => true

  # hookers

  # validations
  validates_with_block :json do
    @json_errors = {}
    cat_card.json.each do |key, type|
      if type[0].to_sym == :json && json[key].kind_of?(String)
        begin
          json[key] = MultiJson.load(json[key])
        rescue Exception => e
          @json_errors[key] = e.message.force_encoding('utf-8')
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
