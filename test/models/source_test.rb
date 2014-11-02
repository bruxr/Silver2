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
    
    VCR.use_cassette('sources/find_sources') do 
      sources = Source.find_sources_for('Iron Man', year: 2008)
      actual = []
      sources.each do |source|
        actual << source.attributes
      end
      assert_equal(expected, actual)
    end
  end
  
  # TODO: do we really need to time travel here?
  test 'should not create duplicate sources' do
    Delorean.time_travel_to('2003-01-01') do 
      VCR.use_cassette('sources/no_duplicates') do
        movie = movies(:aragorn)
        movie.find_sources!
        movie.save
        movie.find_sources!
        assert_equal(4, movie.sources.length)
      end
    end
  end
  
  test 'should update parent movie scores whenever a source is deleted' do
    VCR.use_cassette('sources/update_scores_when_deleted') do
      movie = movies(:nightcrawler)
      movie.sources.last.destroy
      assert_equal(8.3, movie.aggregate_score)
    end
  end

end
