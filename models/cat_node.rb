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

  # relations
  belongs_to :cat_card, :required => true

  # hookers

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
