#coding:utf-8
class FormsResult
  include DataMapper::Resource

  property :id,       Serial
  property :created_at, DateTime

  amorphous!

  # relations
  belongs_to :forms_card, :required => true

  # hookers

  # instance helpers

  # class helpers

end
