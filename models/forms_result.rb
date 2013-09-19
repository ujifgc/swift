class FormsResult
  include DataMapper::Resource

  property :id,         Serial
  property :created_at, DateTime
  property :origin,     String, :length => 31
  property :number,     Integer

  amorphous!

  # relations
  belongs_to :forms_card, :required => true
  belongs_to :created_by, 'Account', :required => false

  # hookers
  before :valid? do
    self.origin = origin[0..30]
    self.number = FormsResult.all( :forms_card => Bond.children_for(forms_card, 'FormsCard') + [forms_card], :id.not => id ).max(:number).to_i + 1
  end
  
  after :save do
    forms_card.reset_statistic     
  end

  after :destroy do |old|
    old.forms_card.json.select do |k, v|
      v[0] == 'file'
    end.each do |k, v|
      Asset.all(:id => old.json[k]).destroy
    end
  end

  # validations
  validates_with_block :json do
    @json_errors = {}
    forms_card.json.each do |key, type|
      if type[2] && json[key].blank?
        @json_errors[key] = I18n.t('datamapper.errors.messages.json_required')
      end
    end
    if @json_errors.any?
      [false, I18n.t('datamapper.errors.messages.json_error')]
    else
      true
    end
  end

  # instance helpers
  def title
    I18n.l( created_at, :format => :datetime )
  end
end
