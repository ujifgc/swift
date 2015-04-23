Admin.helpers do
  def detect_current_model
    @the_model = begin
      @models = request.controller || params[:controller]
      @model = @models.singularize
      @models = @models.to_sym
      @model_name = @model.camelize
      @model = @model.to_sym
      Object.const_defined?(@model_name)  or throw :undefined
      @model_name.constantize
    rescue
      nil
    end
  end

  def get_current_object
    @object = @the_model.get(params[:id])
    unless @object
      flash[:error] = pat('object.not_found')
      redirect url(@models, :index)
    end
  end

  def url_after_save
    if params[:apply]
      url(@models, :edit, @object.id)
    else
      url(@models, :index)
    end
  end

  def load_protocol_attributes
    if protocol = Protocol.get(params[:protocol_id])
      protocol.object.each do |key, value|
        method = "#{key}="
        @object.send(method, value) if @object.respond_to?(method)
      end
    elsif params[:protocol_id].present?
      flash.now[:error] = pat('protocol.not_found')
    end
  end
end
