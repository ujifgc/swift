class Images < Sequel::Model
  plugin :nozzle, :file, ImageAdapter

  many_to_one :folder, :class => :Folders
end
