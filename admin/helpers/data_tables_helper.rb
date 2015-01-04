require 'ostruct'

Admin.helpers do
  def mk_data_table( model )
    @columns = model.dynamic_columns
    @dynamic = "dynamic"
    partial 'base/data-table'
  end

  def mk_group_selector( model, group, params, options = {} )
    filter = options[:filter] || {}
    @groups = {}
    case group
    when Hash
      group.each do |name, variants|
        @group_name = name.to_s
        @groups[@group_name] = variants.map{ |k,v| OpenStruct.new(:id => k, :title => v) }
        selected = params[@group_name]
        @selected ||= {}
        @selected[@group_name] = {} 
        @selected[@group_name][selected] = true if selected
      end
    else
      @group_name = group.name.singularize.underscore
      @groups[@group_name] = options[:with] ? group.with(options[:with]) : group.all(filter)
      selected = params[@group_name]
      @selected ||= {}
      @selected[@group_name] = {} 
      @selected[@group_name][selected] = true if selected
    end
    if options[:instance].blank?
      partial 'base/group-select'
    elsif options[:instance] == 'for-bonds'
      partial 'base/group-select-for-bonds'
    end
  end

  def show_json(data, types)
    types.map do |key, field_settings|
      if field_settings[0] == 'file'
        if data[key].present?
          data[key].map do |id|
            if asset = Asset.get(id)
              link_to(asset.title, asset.file.url)
            end
          end.join(', ').html_safe
        end
      else
        "#{key}: #{data[key]}" if data[key].present?
      end
    end.compact.join('<br>').html_safe
  end
end
