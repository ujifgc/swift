class NewsArticles < Sequel::Model
  plugin :publishable

  def has_image?
    !!image_matchdata
  end

  def image
    @image ||= image_matchdata && Images.with_pk(image_matchdata[1])
  end

  private

  def image_matchdata
    @image_matchdata ||= (info + text).match(Swift::Helpers::Utils::REGEX_IMAGE_ID)
  end
end
