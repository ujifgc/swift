class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  def store_dir
    case
    when !model.folder
      'img/other'
    when model.folder.slug == 'images'
      'img'
    when model.folder.slug.blank?
      'img/' + model.folder.id.to_s
    else
      'img/' + model.folder.slug
    end
  end

  def filename
    @time_stamp ||= Time.now.strftime('%y%m%d%H%M%S')
    if model.folder && model.folder.slug == 'images'
      original_filename
    else
      [@time_stamp,original_filename].compact.join('_')  if original_filename.present?
    end
  end

  def default_url
    '/images/image_missing.png'
  end

  def root
    Padrino.public
  end

  def content_type
    #`file -bp --mime-type #{root}#{url}`.to_s.strip
    model.file_content_type || ''
  end

  def size
    model.file_size || -1
  end

end


class AssetUploader < CarrierWave::Uploader::Base

  def store_dir
    case
    when !model.folder
      'doc'
    when model.folder.slug.blank?
      'doc/' + model.folder.id.to_s
    else
      'doc/' + model.folder.slug
    end
  end

  def filename
    @time_stamp ||= Time.now.strftime('%y%m%d%H%M%S')
    [@time_stamp, original_filename].compact.join('_')  if original_filename.present?
  end

  def root
    Padrino.public
  end

  def content_type
    #`file -bp --mime-type #{root}#{url}`.to_s.strip
    model.file_content_type || ''
  end

  def size
    model.file_size || -1
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
