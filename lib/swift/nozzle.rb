require 'shellwords'

class NeatAdapter < Nozzle::Adapter::Base

  def size
    #return -1
    #raise Exception, 'not implemented'
    @record.file_size || -1
  end

  def content_type
    #return 'not/implemented'
    #raise Exception, 'not implemented'
    #`file -bp --mime-type '#{root}#{url}'`.to_s.strip
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

  outlet :thumb do
    def prepare( original, result )
      FileUtils.mkdir_p File.dirname(result)
      `convert #{Shellwords.escape original} -thumbnail 180x135 #{Shellwords.escape result}`
    end
    def relative_folder
      "cache/#{@model}"
    end
    def filename
      "#{@record.id}@#{version_name}-#{super}"
    end
  end

  outlet :fill_thumb do
    def prepare( original, result )
      FileUtils.mkdir_p File.dirname(result)
      `convert #{Shellwords.escape original} -thumbnail 180x135^ -gravity center -extent 180x135 #{Shellwords.escape result}`
    end
    def relative_folder
      "cache/#{@model}"
    end
    def filename
      "#{@record.id}@#{version_name}-#{super}"
    end
  end

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
