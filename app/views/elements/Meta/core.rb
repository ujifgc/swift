object = @swift[:resource] || @page
@meta = object.respond_to?(:meta) ? object.meta : {}
if object.respond_to?(:info) && @meta['description'].blank?
  @meta['description'] = strip_code( object.info.present? ? object.info : object.title )
end
