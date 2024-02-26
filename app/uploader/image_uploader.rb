# frozen_string_literal: true

class ImageUploader < CarrierWave::Uploader::Base
  storage :file

  def extension_whitelist
    %w[png jpg jpeg gif]
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
end
