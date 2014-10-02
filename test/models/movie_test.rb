require 'test_helper'

class MovieTest < ActiveSupport::TestCase
  
  test 'should correctly fix titles' do
    movie = Movie.new
    movie.title = 'The Expandables'
    movie.fix_title
    assert_equal('The Expendables', movie.title)
  end

end
