class Blocks < Sequel::Model
  Types = {
    0 => :text,
    1 => :html,
    2 => :table,
  }

  plugin :sluggable

  def type?(tested_type)
    Types[type] == tested_type.to_sym
  end
end
