Admin.controllers :multiple do
  set_access :admin, :designer, :auditor

  helpers do
    def detect_distinct_values
      @distinct_values = {}
      @selected_values = {}
      @the_model.properties.each do |property|
        @distinct_values[property.name] = Set.new
        @objects.each do |object|
          @distinct_values[property.name] << object.send(property.name)
        end
        @selected_values[property.name] = @distinct_values[property.name].count > 1 ? '' : @distinct_values[property.name].first
      end
    end
  end

  get :edit, :with => :models do
    detect_current_model(params[:models])
    ids = params[:ids].split
    @objects = @the_model.all(:id => ids)
    detect_distinct_values
    render 'multiple/edit'
  end

  patch :edit, :with => :models do
    detect_current_model(params[:models])
    ids = params[:ids].split
    @objects = @the_model.all(:id => ids)
    unless params[:object].kind_of?(Hash)
      flash[:error] = pat('multiple.no_fields_available')
      redirect url_after_save
    end
    modifications = Hash[params[:object].select{ |key, value| value.present? && Admin::MULTIPLE_EDIT_FIELDS.include?(key) }]
    if modifications.empty?
      flash[:error] = pat('multiple.no_values_selected')
      redirect url_after_save
    end
    @objects.each do |object|
      modifications.each do |field, value|
        object.send("#{field}=", value)
      end
      object.save
    end
    detect_distinct_values
    redirect url_after_save
  end
end
