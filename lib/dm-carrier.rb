class NeatUploader < CarrierWave::Uploader::Base

  def uri_encode_url(url)
    if url = Addressable::URI.parse(url) #!!! FIXME this is bullcrap
      url.path = uri_encode_path(url.path)
      url.to_s
    end
  rescue URI::InvalidURIError
    url
  end

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
    if model.folder && model.folder.is_private
      Padrino.root 'private'
    else
      Padrino.public
    end
  end

  def content_type
    #`file -bp --mime-type '#{root}#{url}'`.to_s.strip
    model.file_content_type || ''
  end

  def original_filename
    ( model.respond_to?(:upload_name) && model.upload_name.present? ) ? model.upload_name : super
  end

  def base_dir
    'base'
  end

  def store_dir
    case
    when !model.folder
      base_dir + '/other'
    when model.folder.slug == 'images'
      base_dir
    when model.folder.slug.blank?
      base_dir + '/' + model.folder.id.to_s
    else
      base_dir + '/' + model.folder.slug
    end
  end

  def url
    if !model.folder || !model.folder.is_private
      super
    else
      '/admin/private' + super
    end
  end  

  def filename
    @time_stamp ||= Time.now.strftime('%y%m%d%H%M%S')
    [@time_stamp, original_filename].compact.join('_')  if original_filename.present?
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

  def base_dir
    'img'
  end

  def filename
    if model && model.folder && model.folder.slug == 'images'
      original_filename
    else
      super
    end
  end

end


class AssetUploader < NeatUploader

  def base_dir
    'doc'
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
