require 'test_helper'

class MovieTest < ActiveSupport::TestCase
  
  test 'fixing titles' do
    movie = Movie.new
    movie.title = 'The Expandables'
    movie.fix_title
    assert_equal('The Expendables', movie.title)
  end

end
