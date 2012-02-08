class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  def store_dir
    path = ['public/images']
    if model && model.folder
      path << model.folder.slug  unless model.folder_id == 1
    end
    File.join path
  end

  def filename
    [Time.now.strftime('%y%m%d%H%M%S'), original_filename].compact.join('_') + file.extension  if original_filename.present?
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
