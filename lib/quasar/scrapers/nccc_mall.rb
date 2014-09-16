module Quasar
  module Scrapers

    # A Quasar Fetcher for NCCC Mall of Davao Cinemas
    # Instantiate and invoke get_schedules() to 
    # return an array of screening times.
    class NcccMall < Quasar::Scrapers::Base

      # Grabs schedules from NCCC's cinema page
      def get_schedules

        @schedules = []

        require 'nokogiri'

        resp = get('http://nccc.com.ph/main/page/cinema')
        doc = Nokogiri::HTML(resp)

        # Extract effective dates
        dates = doc.css('.movie-info-contact').first.content.gsub('Running Date:', '').strip.split(' - ')
        start_date = Date.parse(dates[0])
        end_date = Date.parse(dates[1])

        # Loop through each movie title
        doc.css('.movie-thumbnail-nowshowing').each do |movie_div|

          # Loop through each info <div>
          movie_div.search('.movie-title').each do |div|

            # Extract the title
            title = div.children.first.content

            # Build movie hash
            movie = {}
            movie[:name] = title.gsub(/\s(?:2|3)D\z/, '')
            movie[:schedules] = []

            # Extract the rating
            blocks = div.inner_html.split('<br>')
            movie[:rating] = blocks[1]

            # If rating is PG-13, convert it to PG to match MTRCB's ratings
            if movie[:rating] == 'PG-13'
              movie[:rating] = 'PG'
            end

            # Determine the format based on the title's suffix
            # (They're suffixed with a 2D or 3D depending on the format)
            if title =~ /3D\z/
              format = '3D'
            else
              format = '2D'
            end

            # Determine the cinema
            cinema_name = movie_div.search('div').first.attribute('class').content.gsub('cinema', 'Cinema ')

            # Extract screening times
            screening_times = []
            reached_noon = false
            div.content.scan(/\d{1,2}\:\d{2,2}/) do |time|
              hour = time.split(':')[0]
              reached_noon = true if hour == '12' # set a flag if we're in noon
              if reached_noon
                screening_times << time.concat(' PM')
              else
                screening_times << time.concat(' AM')
              end
            end

            # Loop through each effective date and build schedule data
            start_date.upto(end_date) do |date|
              
              # Loop through the screening times, then build the screening hash
              screening_times.each do |time|
                screening_time = date.to_s.concat(" #{time}")
                screening = {
                  cinema_name: cinema_name,
                  price: nil,
                  time: Time.zone.parse(screening_time),
                  format: format,
                  ticket_url: nil
                }
                movie[:schedules] << screening
              end

            end

            @schedules << movie

          end # end loop through each title <div>

        end

        return @schedules

      end

    end

  end
end