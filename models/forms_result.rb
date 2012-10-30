#coding:utf-8
class FormsResult
  include DataMapper::Resource

  property :id,         Serial
  property :created_at, DateTime
  property :origin,     String, :length => 31

  amorphous!

  # relations
  belongs_to :forms_card, :required => true
  belongs_to :created_by, 'Account', :required => false

  # hookers
  before :valid? do
    self.origin = self.origin[0..30]
  end
  
  after :save do
    forms_card.reset_statistic     
  end

  # instance helpers
  def title
    I18n.l( self.created_at, :format => :datetime )
  end

  # class helpers

end
