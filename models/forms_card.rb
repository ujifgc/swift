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

  property :id,       Serial

  property :title,    String, :required => true
  property :text,     Text

  sluggable!
  timestamps!
  userstamps!
  amorphous!
  bondable!

  # relations
  has n, :forms_results

  # hookers

  # instance helpers

end
