object = @swift[:resource] || @page

@meta = object.respond_to?(:meta) ? object.meta : {}
@meta['description'] ||= object.respond_to?(:info) && object.info.present? && object.info || object.title
