require 'ostruct'

Admin.helpers do
  def mk_data_table( model )
    @columns = model.dynamic_columns
    @dynamic = "dynamic"
    partial 'base/data-table'
  end

  def mk_group_selector( model, group, params, options = {} )
    filter = options[:filter] || {}
    case group
    when Hash
      group.each do |name, variants|
        # !!! FIXME many groups?
        @groups = variants.map{ |k,v| OpenStruct.new(:id => k, :title => v) }
        @group_name = name.to_s
      end
    else
      @groups = options[:with] ? group.with(options[:with]) : group.all(filter)
      @group_name = group.name.singularize.underscore
    end
    @selected = {}
    selected_id = params[:"#{@group_name}_id"].to_i
    @selected[selected_id] = true  if selected_id > 0
    partial 'base/group-select'
  end
end
