require 'test_helper'

class MetacriticTest < ActiveSupport::TestCase
  
  test 'should be able to find the correct movie' do
    VCR.use_cassette('metacritic/find_correct_movie') do
      resp = Metacritic.new.find_title('Ouija', 2014)
      assert_equal('Ouija', resp[:id])
    end
  end
  
  test 'should return nil if a movie has no ratings' do
    VCR.use_cassette('metacritic/check_no_score') do
      resp = Metacritic.new.get_score('Blood Ransom')
      assert_equal(nil, resp)
    end
  end
  
end