require 'test_helper'

class OmdbTest < ActiveSupport::TestCase
  
  test 'should be able to find the correct movie' do
    VCR.use_cassette('test/omdb/find_correct_movie') do
      resp = Omdb.new.find_title('Ouija', 2014)
      assert_equal('tt1204977', resp[:id])
    end
  end
  
end