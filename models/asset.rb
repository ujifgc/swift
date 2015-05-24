class Assets < Sequel::Model
  plugin :nozzle, :file, AssetAdapter

  many_to_one :folder, :class => :Folders

  def info
    "#{title} (#{mime})"
  end

  def mime
    "#{file.content_type}, #{file.size.as_size}"
  end
end
