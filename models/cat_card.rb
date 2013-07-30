#coding:utf-8
class CatCard
  include DataMapper::Resource

  Types = {
    'Строка'   => :string,
    'Число'    => :number,
    'Вариант'  => :select,
    'Выборка'  => :multiple,
    'Файлы'    => :assets,
    'Картинки' => :images,
    'Дата'         => :date,
    'Дата и время' => :datetime,
    'Объект'   => :json,
  }

  property :id,       Serial

  property :title,    String, :required => true
  property :text,     Text

  sluggable!
  timestamps!
  userstamps!
  loggable!
  amorphous!
  bondable!
  recursive!

  # relations
  has n, :cat_nodes
end
