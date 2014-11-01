require 'test_helper'

class RottenTomatoesTest < ActiveSupport::TestCase
  
  test 'should be able to find the correct movie' do
    VCR.use_cassette('rotten_tomatoes/find_correct_movie') do
      resp = RottenTomatoes.new.find_title('Ouija', 2014)
      assert_equal(771373980, resp[:id])
    end
  end
  
end