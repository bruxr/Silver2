require 'test_helper'

class MovieTest < ActiveSupport::TestCase
 
# Find a better way of fixing titles, since we
# really need to have the exact title to get a match.
# 
#  test 'should correctly fix titles' do
#    Delorean.time_travel_to('June 6 2004') do
#      VCR.use_cassette('movies/fix_title') do
#        actual = Movie.fix_title('The Expandables')
#        assert_equal('The Expendables', actual)
#      end
#    end
#  end

  test 'should correctly update scores' do
    Delorean.time_travel_to('November 11 1997') do
      VCR.use_cassette('movies/update_scores') do
        movie = movies(:airforceone)
        movie.find_sources!
        movie.update_scores!
        assert_not_nil(movie.aggregate_score)
      end
    end
  end

  test 'should find a trailer' do
    VCR.use_cassette('movies/find_trailer') do
      movie = movies(:aragorn)
      movie.find_trailer!
      assert_not_nil(movie.trailer)
    end
  end

  test 'should be able to mark movies with complete details as ready' do
    Delorean.time_travel_to('December 27 2003') do
      VCR.use_cassette('movies/mark_ready') do
        movie = movies(:aragorn)
        movie.find_sources!
        movie.find_details!
        movie.find_trailer!
        movie.update_status
        assert_equal('ready', movie.status)
      end
    end
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
  
  test 'should be able to correctly count upcoming schedules' do
    movie = Movie.first
    movie.schedules << Schedule.new(cinema_id: Cinema.first.id, screening_time: Time.now + 1.day, format: '2D', room: 'Cinema 9')
    assert_equal(1, movie.schedule_count(:upcoming))
  end
  
  test 'should be able to correctly count cinemas with upcoming schedules' do
    movie = Movie.first
    movie.schedules << Schedule.new(cinema_id: Cinema.first.id, screening_time: Time.now + 1.day, format: '2D', room: 'Cinema 9')
    assert_equal(1, movie.cinema_count(:upcoming))
  end

end
