require 'test_helper'

class RottenTomatoesTest < ActiveSupport::TestCase

  test 'should return the correct title and ID when searching with a title' do
    expected = {
      id: 16823,
      title: 'Air Force One'
    }
    rt = Quasar::WebServices::RottenTomatoes.new(ENV['RT_API_KEY'])
    actual = rt.find_title('Air Force One')
    assert_equal(expected, actual)
  end

  test 'should return the correct movie details' do
    rt = Quasar::WebServices::RottenTomatoes.new(ENV['RT_API_KEY'])
    actual = rt.get_details(10156)
    assert_equal('The Lord of the Rings: The Return of the King', actual['title'])
  end

end