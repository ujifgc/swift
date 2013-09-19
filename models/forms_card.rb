#coding:utf-8
class FormsCard
  include DataMapper::Resource

  Types = {
    'Строка'      => :string,
    'Комментарий' => :text,
    'Число'       => :number,
    'Вариант'     => :select,
    'Выборка'     => :multiple,
    'Файл'        => :file,
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
  property :receivers,    String

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
  property :folder_id, Integer
  belongs_to :folder, :required => false

  # hookers
  before :save do
    self.statistic = {}     
  end
  
  # instance helpers
  def fill( request )
    object = request.params['forms_result'] || {}
    json.each do |k, v|
      if v[0] == 'file'
        object.delete(k)  unless object[k].kind_of? Array
      end
    end
    object[:forms_card] = self
    object[:created_by] = nil # FIXME
    object[:origin] = request.addr
    res = FormsResult.create object
    res
  end

  def stat( key, var, unit = :percent )
    results = forms_results
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
    save!
  end
end
