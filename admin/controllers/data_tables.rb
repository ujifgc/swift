class NewsArticle
  def self.admin_columns
    columns = {
      :id          => { :code => 'mk_checkbox o', :head_class => 'last' },
      :title       => { :code => 'mk_edit o', :body_class => 'wide' },
      :news_rubric => { :code => 'o.news_rubric && o.news_rubric.title' },
      :date        => { :code => "o.date.kind_of?(DateTime) ? I18n.l( o.date, :format => :date ) : ''" },
      :publish_at  => { :code => "o.publish_at.kind_of?(DateTime) ? I18n.l( o.publish_at, :format => :date ) : ''" },
    }
    columns.keys.each do |k|
      columns[k][:header_title] = I18n.t("models.object.attributes.#{k}")
      case k
      when :date, :publish_at, :created_at, :updated_at, :news_rubric
        columns[k][:data] ||= {}
        columns[k][:data][:nowrap] = true
      end
    end
    columns
  end
end

Admin.controllers :data_tables do
  get :index, :with => [ :model ] do
    Logger params
    model = params[:model].singularize.camelize.constantize  rescue error(501)
    columns = model.admin_columns  rescue error(501)

    paginator = {}
    paginator[:offset] = params[:iDisplayStart].to_i
    paginator[:offset] = 0  if paginator[:offset] < 0
    paginator[:limit] = params[:iDisplayLength].to_i
    paginator.delete(:limit)  if paginator[:limit] < 0

    filter = { }
    filter[:title.like] = '%' + params[:sSearch] + '%'

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
