# encoding: utf-8

require 'carrierwave/processing/rmagick'
class PosterUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick
  storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    'posters'
  end

  # Process files as they are uploaded:
  process :resize_to_limit => [342, 513]

  # Add a white list of extensions which are allowed to be uploaded.
  def extension_white_list
     %w(jpg jpeg gif png)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

end
