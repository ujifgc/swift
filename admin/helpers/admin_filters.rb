Admin.helpers do
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
