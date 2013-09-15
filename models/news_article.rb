class NewsArticle
  include DataMapper::Resource

  property :id,       Serial

  property :title,    String
  property :info,     Text
  property :text,     Text

  sluggable!
  timestamps!
  userstamps!
  loggable!
  publishable!
  bondable!
  dateable!
  metable!
  datatables!( :columns => {
    :id          => { :code => 'mk_checkbox o', :head_class => 'last' },
    :title       => { :code => 'mk_edit o', :body_class => 'wide' },
    :news_rubric => { :code => 'o.news_rubric && o.news_rubric.title' },
    :date        => { :code => "o.date.kind_of?(DateTime) ? I18n.l( o.date, :format => :date ) : ''" },
    :publish_at  => { :code => "o.publish_at.kind_of?(DateTime) ? I18n.l( o.publish_at, :format => :date ) : ''" }
  })

  # relations
  property :news_rubric_id, Integer, :default => 1
  belongs_to :news_rubric, :required => true

  # validations
  validates_presence_of      :title

  # hookers

  # instance helpers
end
