require 'test_helper'

class Metacritic_Test < ActiveSupport::TestCase

  test 'should return the correct title and ID when searching with a title' do
    expected = {
      id: 'Fast & Furious 6',
      title: 'Fast & Furious 6'
    }
    rt = Quasar::WebServices::Metacritic.new(ENV['MASHAPE_API_KEY'])
    actual = rt.find_title('Fast & Furious')
    assert_equal(expected, actual)
  end

  test 'should return the correct movie details' do
    rt = Quasar::WebServices::Metacritic.new(ENV['MASHAPE_API_KEY'])
    actual = rt.get_details('The Expendables 3')
    assert_equal('http://www.metacritic.com/movie/the-expendables-3', actual['url'])
  end

end