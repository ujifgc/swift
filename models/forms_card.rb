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
    'Вопрос — ответ' => 'faq',
  }

  property :id,       Serial

  property :title,    String, :required => true
  property :text,     Text
  property :kind,     String, :length => 10, :default => 'form'

  sluggable!
  timestamps!
  userstamps!
  amorphous!
  bondable!
  publishable!

  # relations
  has n, :forms_results

  # hookers

  # instance helpers
  def fill( request )
    object = request.params['forms_result'] || {}
    object[:forms_card] = self
    object[:created_by] = nil # FIXME
    object[:origin] = request.addr
    res = FormsResult.create object
    res
  end

end
