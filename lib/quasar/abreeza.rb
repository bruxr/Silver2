# A Quasar Fetcher for Abreeza Cinemas
# Instantiate and invoke get_schedules() to 
# return an array of screening times.
# 
# TODO: find out how ayala displays 3d movies
require "nokogiri"
require 'awesome_print'
class Quasar::Abreeza < Quasar::Fetcher

  def get_schedules
    
    data = {
      tid: 'ABRZ',
      day: '',
      time: '#'
    }
    resp = get 'http://www.sureseats.com/theaters/search.asp', data
    doc = Nokogiri::HTML resp

    # Loop through each movie title
    doc.css('td.SEARCH_TITLE').each do |movie_title|

      movie = {}
      movie[:name] = movie_title.content
      movie[:schedules] = []

      # Find the <table> for this movie
      table = movie_title.parent.parent

      # Determine the cinema
      cinema_name = table.search('.CINEMA_NUMBER').first.content

      # and the price
      price = table.search('.SEARCH_PRICE').first.content.sub! 'Price: ', ''
      price = price.to_f

      # and the format
      # TODO: should be able to determine if movie is in 3D
      format = '2D'

      # and the ticket url
      ticket_url = 'http://sureseats.com' << table.search('a.BLUE').first.attribute('href').content

      # Determine the date
      date = table.search('.SEARCH_DATE').first.content

      # Compile the screening times
      times = []
      table.search('.SEARCH_SCHED,.MOVIE_SCHED_DISABLED').each do |time|
        screening = {
          cinema_name: cinema_name,
          price: price,
          time: Time.zone.parse("#{date} #{time.content}"),
          format: format,
          ticket_url: ticket_url
        }
        movie[:schedules] << screening
      end

      @schedules << movie

    end

    @schedules

  end

end