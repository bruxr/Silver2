require 'test_helper'

class MovieTest < ActiveSupport::TestCase
  
  test 'should correctly fix titles' do
    actual = Movie.fix_title('The Expandables')
    assert_equal('The Expendables', actual)
  end

end
