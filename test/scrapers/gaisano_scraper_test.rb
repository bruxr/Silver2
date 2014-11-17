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
  
  # Found on Nov 16 2014
  # -------------------------------
  # CINEMA 5
  # THE DROP 
  # TOM HARDY|NOOMI RAPACE
  # R16- Crime|Drama
  # 10:40|12:35|2:35
  #
  # NIGHTCRAWLER 
  # JAKE GYLLENHAAL|RENE RUSSO
  # R16- Crime|Thriller|Drama
  # 4:40|7:10|9:30
  #
  # P130 <-- shared ticket price
  test 'should detect shared ticket prices' do
    VCR.use_cassette('gaisano_scraper/shared_prices') do
      skeds = GaisanoMall.new.schedules
      assert_equal(skeds[5][:schedules][11][:price], 130)
    end
  end
  
end