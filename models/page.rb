class Pages < Sequel::Model
  plugin :serialization, :json, :meta
  plugin :publishable

  many_to_one :parent, :class=>self
  one_to_many :children, :key=>:parent_id, :class=>self
#  alias_method :children, :children_dataset

  def self.root
    first(:parent_id => nil)
  end

  def last_update
    case
    when is_system && slug == 'news'
      NewsArticle.last(:order => :updated_at).updated_at
    else
      updated_at
    end
  end
end
