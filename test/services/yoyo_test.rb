require 'test_helper'

class YoyoTest < ActiveSupport::TestCase
  
  test 'should be able to download & upload to S3' do
    url = 'http://kiranatama.com/assets/slider/ruby-53272f15396c2222cc0f9899fd13fb9f.png'
    s3_url = Yoyo.download(url).upload_using! PosterUploader
    assert_not_nil(s3_url)
  end
  
end