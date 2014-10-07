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

  test 'should find a trailer' do
    movie = movies(:aragorn)
    movie.find_trailer
    assert_not_nil(movie.trailer)
  end

  test 'should be able to mark movies with complete details as ready' do
    movie = movies(:aragorn)
    movie.sources.search
    movie.find_details
    movie.find_trailer
    movie.update_status
    assert_equal('ready', movie.status)
  end

  test 'should be able to fetch the best poster' do
    movie = movies(:airforceone)
    movie.sources.search
    assert_not_nil(movie.get_poster)
  end

end
