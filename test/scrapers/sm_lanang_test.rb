require 'test_helper'

class SmLanangTest < ActiveSupport::TestCase
  
  test 'should catch IMAX format' do
    VCR.use_cassette('sm_lanang_scraper/detect_imax') do
      skeds = SmLanang.new.schedules
      ap skeds
      assert_equal(skeds[2][:schedules][2][:format], 'IMAX')
    end
  end
  
end