require 'test_helper'

class MetacriticTest < ActiveSupport::TestCase
  
  test 'should be able to find the correct movie' do
    VCR.use_cassette('metacritic/find_correct_movie') do
      resp = Metacritic.new.find_title('Ouija', 2014)
      assert_equal('Ouija', resp[:id])
    end
  end
  
  # Tests metacritic if it can find the correct movie that uses
  # numbers after the title (Iron Man, Iron Man 2, Iron Man 3)
  test 'should be able to find iron man' do
    VCR.use_cassette('metacritic/find_iron_man') do
      resp = Metacritic.new.find_title('Iron Man', 2008)
      assert_equal('Iron Man', resp[:id])
    end
  end
  
  test 'should return nil if a movie has no ratings' do
    VCR.use_cassette('metacritic/check_no_score') do
      resp = Metacritic.new.get_score('Blood Ransom')
      assert_equal(nil, resp)
    end
  end
  
end