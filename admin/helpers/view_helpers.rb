Admin.helpers do
  def tag_icon(icon, tag = nil)
    content = content_tag(:i, '', :class=> "icon-#{icon}")
    content << " #{tag}"
  end

  def padrino_admin_translate(word, default=nil)
    t("padrino.admin.#{word}", :default => default).to_s.html_safe
  end
  alias :pat :padrino_admin_translate

  def model_attribute_translate(model, attribute)
    t("models.#{model}.attributes.#{attribute}").to_s.html_safe
  end
  alias :mat :model_attribute_translate

  def model_translate(model)
    t("models.#{model}.name").to_s.html_safe
  end
  alias :mt :model_translate
end
