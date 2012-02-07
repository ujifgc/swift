require 'carrierwave/datamapper'

class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
end
