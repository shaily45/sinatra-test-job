class ImageUploader < CarrierWave::Uploader::Base
  storage :file

  def extension_whitelist
    %w[png jpg jpeg gif]
  end
end
