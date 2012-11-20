class NeatUploader < CarrierWave::Uploader::Base

  def kill_cache
    path = File.expand_path(cache_dir, root)
    FileUtils.rm_rf @@kill_list.map{|dir| File.expand_path(dir, path) }
    @@kill_list = []
  end

  def move_to_cache
    @@kill_list ||= []
    @@kill_list << @cache_id
    false
  end

  def size
    model.file_size || -1
  end

  def root
    Padrino.public
  end

  def content_type
    #`file -bp --mime-type #{root}#{url}`.to_s.strip
    model.file_content_type || ''
  end

end

class ImageUploader < NeatUploader
  include CarrierWave::MiniMagick

  version :thumb do
    process :resize_to_fit => [180,135]
    def store_dir
      "cache/#{version_name}/#{model.class.name}/#{model.id}"
    end
  end

  version :fill_thumb do
    process :resize_to_fill => [180,135]
    def store_dir
      "cache/#{version_name}/#{model.class.name}/#{model.id}"
    end
  end

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
    if original_filename
      if model.new?
        @time_stamp ||= Time.now.strftime('%y%m%d%H%M%S')
        if model.folder && model.folder.slug == 'images'
          original_filename
        else
          [@time_stamp,original_filename].compact.join('_')  if original_filename.present?
        end
      else
        model.attribute_get(:file)
      end
    end
  end

  def default_url
    '/images/image_missing.png'
  end

  def render!(version)
    already_cached = cached?
    cache_stored_file!  if !already_cached
    send(version).store!
    kill_cache
    send(version)
  end

end


class AssetUploader < NeatUploader

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
