require 'test_helper'

class RottenTomatoesTest < ActiveSupport::TestCase
  
  test 'should be able to find the correct movie' do
    VCR.use_cassette('rotten_tomatoes/find_correct_movie') do
      resp = RottenTomatoes.new.find_title('Ouija', 2014)
      assert_equal(771373980, resp[:id])
    end
  end

  test 'should be able to get ratings from movie pages' do
    VCR.use_cassette('rotten_tomatoes/get_score') do
      score = RottenTomatoes.new.get_score(770740154) # Avengers
      assert_instance_of(Float, score)
    end
  end
  
end