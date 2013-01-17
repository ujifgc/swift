#coding:utf-8
class FormsCard
  include DataMapper::Resource

  Types = {
    'Строка'   => :string,
    'Число'    => :number,
    'Вариант'  => :select,
    'Выборка'  => :multiple,
    'Файлы'    => :assets,
    'Картинки' => :images,
  }
  Kinds = {
    'Форма'    => 'form',
    'Опрос'    => 'inquiry',
  }

  property :id,       Serial

  property :title,    String, :required => true
  property :text,     Text
  property :kind,     String, :length => 10, :default => 'form'
  property :statistic,    DataMapper::Property::Json, :default => {}

  attr_accessor :stats

  sluggable!
  timestamps!
  userstamps!
  loggable!
  amorphous!
  bondable!
  publishable!

  # relations
  has n, :forms_results

  # hookers
  before :save do
    self.statistic = {}     
  end
  
  # instance helpers
  def fill( request )
    object = request.params['forms_result'] || {}
    object[:forms_card] = self
    object[:created_by] = nil # FIXME
    object[:origin] = request.addr
    res = FormsResult.create object
    res
  end

  def stat( key, var, unit = :percent )
    results = self.forms_results
    stats = {}
    cnt = 0
    results.each do |result|
      result.json.each do |k,v|
        stats[k] ||= {}
        if v.kind_of? Array
          v.each do |vv|
            stats[k][vv] ||= 0
            stats[k][vv] += 1
          end
        else
          stats[k][v] ||= 0
          stats[k][v] += 1
        end
      end
      cnt += 1
    end
    val = stats[key][var] rescue key
    case unit
    when :percent
      100 * val / cnt  rescue 0
    else
      val
    end
  end
  
  def reset_statistic()
    self.statistic = {}
    self.save
  end

end
