require 'test_helper'

class GaisanoScraperTest < ActiveSupport::TestCase
  
  # Do not use VCR on scrapers so we can always catch
  # upcoming errors & unexpected data from our
  # source websites.
  test 'should be able to extract movies' do
    skeds = GaisanoMall.new.schedules
    assert_not_nil(skeds)
  end
  
end