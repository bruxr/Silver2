require 'test_helper'

class CinemaTest < ActiveSupport::TestCase
  
  test 'should be able to fetch new schedules' do
    cinema = Cinema.has_scraper.offset(rand(Cinema.has_scraper.count)).first
    new_movies = cinema.schedules.fetch_new
    assert_operator(new_movies.count, '>', 0)
  end

end
