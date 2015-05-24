object = swift.resource || @page
@meta = object.respond_to?(:meta) && object.meta || {}
if @meta['description'].blank?
  @meta['description'] = strip_code( object.respond_to?(:info) && object.info.present? && object.info || object.title )
end
