Admin.helpers do
  def mk_data_table( model )
    @columns = model.dynamic_columns
    @dynamic = "dynamic"
    partial 'base/data-table'
  end

  def mk_group_selector( model, group, params )
    @groups = group.all
    @group_name = group.name.underscore
    @selected = {}
    selected_id = params[:"#{@group_name}_id"].to_i
    @selected[selected_id] = true  if selected_id > 0
    partial 'base/group-select'
  end
end
