#coding:utf-8
class FormsResult
  include DataMapper::Resource

  property :id,       Serial
  property :created_at, DateTime
  property :created_from, String, :length => 31
  property :requires_account, Boolean, :default => false
  property :unique_from,      Boolean, :default => false

  amorphous!

  # relations
  belongs_to :forms_card, :required => true
  belongs_to :created_by, 'Account', :required => false

  # hookers
  before :valid? do
    self.created_from = self.created_from[0..30]
  end

  # instance helpers
  def title
    I18n.l( self.created_at, :format => :datetime )
  end

  # class helpers

end
