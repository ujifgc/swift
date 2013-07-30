Admin.helpers do
  def mk_data_table( model )
    @columns = model.admin_columns
    partial 'base/data-table'
  end
end
