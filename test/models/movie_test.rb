require 'test_helper'

class MovieTest < ActiveSupport::TestCase
  
  test 'should correctly fix titles' do
    actual = Movie.fix_title('The Expandables')
    assert_equal('The Expendables', actual)
  end

  test 'should correctly update scores' do
    movie = movies(:airforceone)
    movie.sources.search
    movie.update_scores
    assert_not_nil(movie.aggregate_score)
  end

end
