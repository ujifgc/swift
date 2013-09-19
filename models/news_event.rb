#coding:utf-8
class NewsEvent
  include DataMapper::Resource

  property :id,       Serial

  property :title,    String
  property :info,     Text
  property :text,     Text
  property :period,   String
  property :duration, String

  Periods = {
    'Нет' => '',
    'Год' => 'year',
    'Месяц' => 'month',
    'Неделя' => 'week',
    'День' => 'day',
  }

  Durations = {
    'час' => 'hour',
    'день' => 'day',
    'неделя' => 'week',
    'месяц' => 'month',
    'год' => 'year',
  }

  sluggable!
  timestamps!
  userstamps!
  loggable!
  publishable!
  dateable!

  # relations
  property :news_rubric_id, Integer, :default => 2
  belongs_to :news_rubric, :required => true

  # validations
  validates_presence_of      :title

  # hookers

  # instance helpers
  def get_duration(what)
    tags = duration.to_s.split '.'
    case what
    when :count
      tags[0]
    when :units
      tags[1]
    end
  end
end
