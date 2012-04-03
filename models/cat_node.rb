class CatNode
  include DataMapper::Resource

  property :id,       Serial

  property :title,    String, :required => true
  property :text,     Text

  sluggable!
  timestamps!
  userstamps!
  publishable!
  bondable!
  amorphous!

  # relations
  belongs_to :cat_card, :required => true

  # hookers

  # instance helpers

  # class helpers
  def self.filter_by( group )
    logger << group.json.inspect
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

    all :conditions => filter
  end

end
