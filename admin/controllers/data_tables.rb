Admin.controllers :data_tables do
  get :index, :with => [ :model ] do
    model = params[:model].singularize.camelize.constantize  rescue error(501)
    columns = model.dynamic_columns  rescue error(501)

    paginator = {}
    paginator[:offset] = params[:iDisplayStart].to_i
    paginator[:offset] = 0  if paginator[:offset] < 0
    paginator[:limit] = params[:iDisplayLength].to_i
    paginator.delete(:limit)  if paginator[:limit] < 0

    filter = { }
    filter[:conditions] = [ 'title LIKE ? OR id LIKE ?', "%#{params[:sSearch]}%", "%#{params[:sSearch]}%" ]

    if params[:sGroup] && params[:sGroupName]
      column_name = :"#{params[:sGroupName]}_id"
      group_id = params[:sGroup].to_i
      filter[column_name] = group_id  if model.properties.named?(column_name) && group_id > 0
    end

    order = { :order => [ ] }
    params[:iSortingCols].to_i.times do |i|
      column_name = columns.keys[params[:"iSortCol_#{i}"].to_i].to_s
      column_name += '_id'  unless model.properties.named? column_name
      next  unless model.properties.named? column_name
      next  if column_name.blank?
      direction = params[:"sSortDir_#{i}"] == 'desc' ? :desc : :asc
      order[:order] << column_name.to_sym.send(direction)
    end
    order[:order] << :updated_at.desc

    result = {}
    result[:iTotalRecords] = model.count
    result[:iTotalDisplayRecords] = model.count filter
    result[:sEcho] = params[:sEcho].to_i
    result[:aaData] = model.all(paginator.merge(filter).merge(order)).map do |o|
      data = {}
      columns.each_with_index do |(k,v),i|
        data[i] = binding.eval(v[:code])
      end
      data[:DT_RowId] = "#{model}-#{o.id}"
      data
    end

    content_type 'application/json'
    result.to_json
  end
end
