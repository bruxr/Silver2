require 'test_helper'

class OmdbTest < ActiveSupport::TestCase
  
  test 'should be able to find the correct movie' do
    VCR.use_cassette('test/metacritic/find_correct_movie') do
      resp = Metacritic.new.find_title('Ouija', 2014)
      assert_equal(resp[:id], 'Ouija')
    end
  end
  
end