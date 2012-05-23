#coding:utf-8
class NewsEvent
  include DataMapper::Resource

  property :id,       Serial

  property :title,    String
  property :info,     Text
  property :text,     Text
  property :period,   String

  Periods = {
    'Нет' => '',
    'Год' => 'year',
    'Месяц' => 'month',
    'Неделя' => 'week',
    'День' => 'day',
  }

  sluggable!
  timestamps!
  userstamps!
  publishable!
  dateable!

  # relations
  property :news_rubric_id, Integer, :default => 2
  belongs_to :news_rubric, :required => true

  # validations
  validates_presence_of      :title

  # hookers

  # instance helpers

end
