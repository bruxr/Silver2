require 'test_helper'

class SourceTest < ActiveSupport::TestCase
  
  test 'should correctly find sources' do
    expected = [
      {
        'id' => nil,
        'movie_id' => nil,
        'name' => 'metacritic',
        'external_id' => 'Iron Man',
        'url' => 'http://www.metacritic.com/movie/iron-man',
        'score' => nil
      },
      {
        'id' => nil,
        'movie_id' => nil,
        'name' => 'omdb',
        'external_id' => 'tt0371746',
        'url' => 'http://www.imdb.com/title/tt0371746',
        'score' => nil
      },
      {
        'id' => nil,
        'movie_id' => nil,
        'name' => 'rt',
        'external_id' => 714976247,
        'url' => 'http://www.rottentomatoes.com/m/iron_man/',
        'score' => nil
      },
      {
        'id' => nil,
        'movie_id' => nil,
        'name' => 'tmdb',
        'external_id' => 1726,
        'url' => 'https://www.themoviedb.org/movie/1726',
        'score' => nil
      }
    ]
    sources = Source.find_movie_sources('Iron Man')
    actual = []
    sources.each do |source|
      actual << source.attributes
    end
    assert_equal(expected, actual)
  end

end
