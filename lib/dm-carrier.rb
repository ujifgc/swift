class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  def store_dir
    case
    when !model.folder
      'pics/other'
    when model.folder.slug == 'images'
      'pics'
    when model.folder.slug.blank?
      'pics/' + model.folder.id.to_s
    else
      'pics/' + model.folder.slug
    end
  end

  def filename
    if model.folder && model.folder.slug == 'images'
      original_filename
    else
      [Time.now.strftime('%y%m%d%H%M%S'), original_filename].compact.join('_')  if original_filename.present?
    end
  end

  def default_url
    '/images/image_missing.png'
  end

  def root
    Padrino.public
  end

end


class AssetUploader < CarrierWave::Uploader::Base

  def store_dir
    case
    when !model.folder
      'docs'
    when model.folder.slug.blank?
      'docs/' + model.folder.id.to_s
    else
      'docs/' + model.folder.slug
    end
  end

  def filename
    [Time.now.strftime('%y%m%d%H%M%S'), original_filename].compact.join('_')  if original_filename.present?
  end

  def root
    Padrino.public
  end

end

module CarrierWave
  module Uploader
    module Versions
      def full_filename(for_file)
        parent_name = super(for_file)
        ext         = File.extname(parent_name)
        base_name   = parent_name.chomp(ext)
        [base_name, version_name].compact.join('_') + ext
      end

      def full_original_filename
        parent_name = super
        ext         = File.extname(parent_name)
        base_name   = parent_name.chomp(ext)
        [base_name, version_name].compact.join('_') + ext
      end
    end
  end
end
