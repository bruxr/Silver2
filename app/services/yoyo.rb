require 'uri'
require 'open-uri'
require 'securerandom'

# A simple class for downloading a file from the internet
# and then uploading it to Amazon S3 by passing it to
# a CarrierWave Uploader.
#
# Start by invoking download:
# Yoyo.download(url)
#
# Then passing it to an uploader:
# Yoyo.download(url).upload_as('Poster')
# - this passes the file to PosterUploader
#   for processing & uploading to S3.
#
# TODO:
#   - Think of a way of streaming the file to S3 directly
#     since Heroku's temporary filesystem can be a problem.
class Yoyo
  
  def self.extract_filename(url)
    uri = URI.parse(url)
    File.basename(uri.path)
  end
  
  def self.download(url)
    name = SecureRandom.hex(3) # Short & sweet
    ext = File.extname(url)
    target = "tmp/%s%s" % [name, ext]
    File.open(target, 'wb') do |destination|
      open(url, 'rb') do |source|
        destination.write(source.read)
      end
    end
    Yoyo.new(target)
  end
  
  def initialize(path)
    @file = File.new(path, 'rb')
    @path = path
  end
  
  def file
    @file
  end
  
  def path
    @path
  end
  
  def upload_using!(klass)
    uploader = klass.new
    uploader.store! @file
    delete!
    
    uploader.file.url
  end
  
  def delete!
    File.delete(@path)
    true
  end
  
end