require 'test_helper'

class OmdbTest < ActiveSupport::TestCase
  
  test 'should be able to find the correct movie' do
    VCR.use_cassette('omdb/find_correct_movie') do
      resp = Omdb.new.find_title('Ouija', 2014)
      assert_equal('tt1204977', resp[:id])
    end
  end
  
  test 'should return nil if a movie has no ratings' do
    VCR.use_cassette('omdb/check_no_score') do
      resp = Omdb.new.get_score('tt2173248')
      assert_equal(nil, resp)
    end
  end
  
end