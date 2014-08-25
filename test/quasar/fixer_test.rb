require 'test_helper'

class FixerTest < ActiveSupport::TestCase

  test 'should return a movie ID and title when searching movies' do
    fixer = Quasar::Fixer.new
    actual = fixer.find_movie('Iron Man')
    expected = { id: 1726, title: 'Iron Man' }
    assert_equal(expected, actual)
  end

  test 'should raise an error if searching yielded no results' do
    fixer = Quasar::Fixer.new
    assert_raises(Exception) do 
      fixer.find_movie('1asd237hdsa352')
    end
  end

  test 'should return movie details when fetching extended details' do
    fixer = Quasar::Fixer.new
    details = fixer.get_details(12153)
    assert_equal('White Chicks', details['title'])
  end

  test 'should raise an error if fetching movie details for a non existent movie ID' do
    fixer = Quasar::Fixer.new
    assert_raises(Exception) do
      fixer.get_details(0000000000000000)
    end
  end

end