require 'shellwords'

class NeatAdapter < Nozzle::Adapter::Base
  def size
    @record.file_size || -1
  end

  def content_type
    @record.file_content_type || ''
  end

  def root
    if @record.folder && @record.folder.is_private
      Padrino.root 'private'
    else
      Padrino.root 'public'
    end
  end

  def adapter_folder
    ''
  end

  def base_dir
    raise Exception, 'not implemented'
  end

  def relative_folder
    folder = @record.folder
    case
    when !folder
      base_dir + '/other'
    when folder.slug == 'images'
      base_dir
    when folder.slug.blank?
      base_dir + '/' + folder.id.to_s
    else
      base_dir + '/' + folder.slug
    end
  end

  def url
    if @record.folder && @record.folder.is_private
      '/admin/private' + super
    else
      super
    end
  end  
end

class ImageAdapter < NeatAdapter
  def default_url
    '/images/image_missing.png'
  end

  def base_dir
    'img'
  end
end

class AssetAdapter < NeatAdapter
  def base_dir
    'doc'
  end
end

module Nozzle
  RESIZE_METHODS = {
    :fit  => '-thumbnail {size}',
    :fill => '-thumbnail {size}^ -gravity center -extent {size}',
  }
  def self.finalize
    outlets = Option(:outlets) || []
    outlets.each do |name,process|
      ImageAdapter.instance_eval do
        outlet name.to_sym do
          @resize_method = RESIZE_METHODS[process.keys.first.to_sym].gsub('{size}', process.values.first)
          def self.resize_method; @resize_method; end
          def prepare( original, result )
            FileUtils.mkdir_p File.dirname(result)
            `convert #{Shellwords.escape original} #{self.class.resize_method} #{Shellwords.escape result}`
          end
          def relative_folder
            "cache/#{@model}"
          end
          def filename
            "#{@record.id}@#{version_name}-#{super}"
          end
        end
      end
    end
  end
end
