require 'test_helper'

class TmdbTest < ActiveSupport::TestCase
  
  test 'should be able to find the correct movie' do
    VCR.use_cassette('test/tmdb/find_correct_movie') do
      resp = Tmdb.new.find_title('Ouija', 2014)
      assert_equal(resp[:id], 242512)
    end
  end
  
end