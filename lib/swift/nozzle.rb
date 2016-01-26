require 'shellwords'

class NeatAdapter < Nozzle::Adapter::Base
  FILES_FOLDER = 'files'
  
  def root(folder=@record.folder)
    if folder && folder.is_private
      Padrino.root 'private'
    else
      Padrino.root 'public'
    end
  end

  def adapter_folder
    ''
  end

  def base_dir
    FILES_FOLDER
  end

  def relative_folder(folder=@record.folder)
    if folder
      File.join(base_dir, folder.path)
    else
      base_dir
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
end

class AssetAdapter < NeatAdapter
end

module Nozzle
  RESIZE_METHODS = {
    :fit  => '-thumbnail {size} -quality 60',
    :fill => '-thumbnail {size}^ -gravity center -extent {size} -quality 60',
  }
  def self.finalize
    check_convert
    outlets = Option(:outlets) || [] rescue []
    outlets.each do |name,process|
      next unless process.kind_of?(Hash)
      ImageAdapter.instance_eval do
        outlet name.to_sym do
          method_name = process.keys.first.to_sym
          @resize_method = RESIZE_METHODS[method_name].gsub('{size}', process.values.first)
          @resize_method.gsub!('>', method_name == :fit ? '\>' : '')

          def self.resize_method
            @resize_method
          end

          def prepare( original, result )
            return original if original.blank?
            begun = Time.now
            FileUtils.mkdir_p File.dirname(result)
            command = "convert #{Shellwords.escape original} #{self.class.resize_method} #{Shellwords.escape result}"
            result = `#{command}`
            logger.devel :exec, begun, command
            result
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

  def self.check_convert
    `convert`
  rescue Errno::ENOENT
    warn 'No `convert` utility found. Please install ImageMagick or fully compatible alternative'
  end
end
