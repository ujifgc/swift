class CatNode
  include DataMapper::Resource

  property :id,       Serial

  property :title,    String, :required => true
  property :text,     Text

  sluggable!
  timestamps!
  userstamps!
  loggable!
  publishable!
  bondable!
  amorphous!

  # relations
  belongs_to :cat_card, :required => true

  # hookers

  # instance helpers

  # class helpers
  def self.filter_by( group )
    filter_strings = []
    filter_regexes = []
    while group
      group.json.each do |key,value|
        filter_strings << 'json REGEXP ?'
        filter_regexes << /\"#{key}\"\:\"#{value}\"/
      end
      group = group.parent
    end
    filter = [filter_strings.join(' AND ')]
    filter += filter_regexes

    if filter[0].length > 0
      all :conditions => filter
    else
      all
    end
  end

end
