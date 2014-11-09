require 'test_helper'

class GaisanoScraperTest < ActiveSupport::TestCase
  
  def setup
    Rails.cache.delete('gaisano_sked_cache')
  end
  
  test 'should be able to extract movies' do
    skeds = GaisanoMall.new.schedules
    assert_not_nil(skeds)
  end
  
  test 'should detect 3D movies' do
    VCR.use_cassette('gaisano_scraper/detect_3d') do
      skeds = GaisanoMall.new.schedules
      assert_equal(skeds[0][:schedules][0][:format], '3D')
    end
  end
  
  test 'should remove 3D suffix from movie titles' do
    VCR.use_cassette('gaisano_scraper/extract_3d_suffix') do
      skeds = GaisanoMall.new.schedules
      assert_equal(skeds[0][:name], 'BIG HERO 6')
    end
  end
  
end