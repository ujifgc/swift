#coding:utf-8
class CatCard
  include DataMapper::Resource

  Types = {
    'Строка'   => :string,
    'Текст'    => :text,
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
  property :sort_cache, DataMapper::Property::Json, :default => {}, :lazy => false
  property :show_fields, DataMapper::Property::Json, :default => {}, :lazy => false

  belongs_to :folder

  sluggable!
  timestamps!
  userstamps!
  loggable!
  amorphous!
  bondable!
  recursive!

  before :valid? do
    self.folder = Folder.for_card(self)
  end

  # relations
  has n, :cat_nodes

  # instance helpers
  def json_of_type(type)
    json.select{ |k, v| v[0] == type.to_s }
  end
end
