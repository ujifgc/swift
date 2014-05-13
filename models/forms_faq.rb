#coding:utf-8
class FormsFaq
  include DataMapper::Resource

  FIELDS = {
    'Сформулируйте свой вопрос' => ['text', '', true, :title],
    'Представьтесь, пожалуйста' => ['string', '', true, :author],
    'Ваш почтовый адрес'        => ['string', '', true, :address],
    'E-mail'                    => ['string', '', false, :email],
    'Дополнительная информация' => ['file', '', false, :asset],
  }

  property :id,       Serial
  property :title,    Text, :required => true, :message => 'Требуется вопрос'
  property :text,     Text

  property :author,   String, :required => true, :message => 'Требуется ФИО'
  property :address,  String, :required => true, :message => 'Требуется почтовый адрес'
  property :email,    String

  property :asset_id, Integer
  belongs_to :asset

  sluggable! :limit => 63
  timestamps!
  userstamps!
  loggable!
  publishable!
end
