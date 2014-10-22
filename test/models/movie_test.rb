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
    assert_not_nil(movie.poster_url)
  end
  
  test 'should be able to create movies from scraped info' do
    scraped = {
      name: 'Air Force One',
      rating: 'PG',
      schedules: [
        {
          time: Time.now + 1.day,
          format: '2D',
          ticket_url: 'http://buymeaticket.com',
          price: 150,
          cinema_name: 'Cinema 1'
        },
        {
          time: Time.now + 1.hour,
          format: '3D',
          ticket_url: 'http://free3dmovies.com', # Shady website lol
          price: 250,
          cinema_name: 'Cinema 2'
        }
      ]
    }
    cinema = Cinema.first
    movie = Movie.process_scraped_movie(scraped, cinema)
    assert_not_nil(movie)
  end

end
