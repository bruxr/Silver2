# The base class for all Gaisano Mall scrapers.
# Uses posts from https://www.facebook.com/gmallcinemas as 
# schedule sources.
#
# The very first scraper will automatically cache the processed
# results for 1 hour so the next one will not need to redo everything since
# all schedules are from one post.
# e.g. Toril scraper first runs will cache results then Bajada scraper
# will just use the cached result instead of doing a request, parsing, etc.
#
# TODO: I know this can be optimized further. Too much loops, splits, joins.
#
# Note to future optimizers:
# The format wildly changes since the post is
# typed by a human. spaces may be missing, newlines suddenly added, line
# orders changed, etc. make sure you account for all of this.
# Only hardcode references (line numbers, ordering) if it's very necessary
# otherwise try using other means like extracting using regex, split>join>split
class GaisanoScraper < Scraper

  ENDPOINT = 'https://graph.facebook.com/v2.1/gmallcinemas/posts'

  def get_schedules
    
    raise 'Gaisano mall name missing.' if self.class::MALL.nil?

    schedules = Rails.cache.fetch("gaisano_sked_cache") do

      # Find the post with the schedules
      post = find_post
      raise 'Cannot find the post containing the schedules.' if post.nil?

      # Extract the date
      dates = extract_dates(post)
      raise 'Cannot extract screening dates.' if dates.blank?

      # Extract the schedules
      blocks = preprocess(post)
      schedules = schedulize(blocks, dates)

      schedules

    end

    raise "Schedules for Gaisano #{self.class::MALL} is missing." if schedules[self.class::MALL].nil?

    schedules[self.class::MALL]

  end

  private

    # Accesses Facebook's Graph API to fetch the page's posts
    # and then returns the post with the schedules.
    def find_post
      
      data = { access_token: "#{ENV['FB_APP_ID']}|#{ENV['FB_APP_SECRET']}" }
      response = get(ENDPOINT, data)
      return nil if response.nil?
      response = JSON.parse(response)

      sked_post = nil
      response['data'].each do |post|
        next if post['message'].nil?
        sked_post = post if post['message'] =~ /\ASKED FOR/
      end

      Sanitize::fragment(sked_post['message'])

    end

    # Extracts the screening date from the schedule post
    # This only matches posts with "SKED FOR OCT. 5" for example,
    # TODO: Should be able to match ranges
    def extract_dates(post)

      dates = []

      # Extract the date part. This matches anything in between
      # SKED FOR and MOVIES ARE IN 2D part
      date_segment = post.match(/SKED\sFOR\s(.+)\.\sMOVIES\sARE\sIN\s2D/)

      # Remove day of week bits
      date_segment = date_segment[1].gsub(/\([A-Z]+\)/, '')

      dates = []
      year = Date.today.strftime('%Y')

      # If for some reason we find a comma in the segment, split the segment
      # then process each part.
      if date_segment =~ /\,/
        date_segment.split(',').map(&:strip).each do |part|
          dates << process_date_part(part)
        end

      # Otherwise, process the segment as normal
      else

        # If there's no dash in the segment, this means it's only for 1 day.
        # Clean it up and then return a date for that day.
        unless date_segment =~ /\-/
          date_segment = date_segment.strip
          return Date.parse("#{date_segment} #{year}")
        end

        # Otherwise, split it then build
        dates = process_date_part(date_segment)

      end

      dates

    end

    # Builds date objects from a date "part".
    # For example: "OCT. 5" or "OCT. 5-OCT. 6"
    def process_date_part(part)

      year = Date.today.strftime('%Y')

      range = []
      part.split('-').map(&:strip).each do |block|
        range << "#{block} #{year}"
      end

      (Date.parse(range[0])..Date.parse(range[1])).to_a

    end

    # Converts a post string to blocks of strings grouped into
    # locations and cinema "rooms".
    def preprocess(post)

      lines = post.split("\n")
      location = cinema = nil
      parsed = {}

      # Process each line and put them into mall & cinema groups
      lines.each do |line|
        
        if line == 'DAVAO' || line == 'TORIL' || line == 'TAGUM'
          location = line
          cinema = nil
          parsed[location] = {}
        elsif line =~ /CINEMA\s[0-9]/
          cinema = line
          parsed[location][cinema] = []
        else
          next if location.nil? || cinema.nil?
          parsed[location][cinema] << line
        end

      end

      # Group our lines into movie blocks
      parsed.each do |location, cinemas|
        cinemas.each do |cinema, lines|
          movies = []
          i = 0
          lines.each do |line|
            movies[i] = [] if movies[i].nil?
            movies[i] << line if line != ''
            i += 1 if line == '' 
          end
          parsed[location][cinema] = movies
        end
      end

      parsed

    end

    # Creates array of schedules from the preprocessed blocks.
    #
    # Note that this method expects a movie "block" to
    # follow this format/line order (as of oct 6 2014).
    # This may change but I can't
    # find a way on how to be more flexible on this:
    # <MOVIE TITLE>
    # <CAST 1>|<CAST 2>|<CAST N>
    # <MTRCB RATING>-<GENRE 1>|<GENRE 2>|<GENRE N>
    # <TIME 1>|<TIME 2>|<TIME N>
    # P<PRICE LOWER DECK>/<PRICE UPPER DECK (can be missing)>
    #
    # TODO: Detect 3D movies
    def schedulize(blocks, dates)

      skeds = {}

      blocks.each do |mall, cinemas|

        next if mall.upcase == 'TAGUM' # Skip tagum schedules
        skeds[mall] = []

        cinemas.each do |cinema, movies|

          movies.each do |lines|

            sked = {}
            sked[:title] = lines[0] # Title on the first line
            
            # MTRCB rating
            sked[:rating] = lines[2].split('-').map(&:strip)[0]
            sked[:rating] = normalize_mtrcb_rating(sked[:rating])

            # Ticket Price
            if lines[4].nil?
              prices = nil
            else
              prices = lines[4].gsub('P', '').split('/').map(&:to_i)
              prices = prices[0] if prices.count == 1 # Flatten price array if contains only 1 price
            end

            # Screening times
            sked[:schedules] = []
            times = extract_screening_times(lines[3], dates)
            times.each do |time|
              sked[:schedules] << {
                cinema_name: cinema.downcase.capitalize,
                price: prices,
                time: time,
                format: '2D',
                ticket_url: nil
              }
            end

            skeds[mall] << sked

          end

        end

      end

      skeds

    end

    # Process lines containing screening times.
    # Returns an array of Time objects that match the
    # extracted screening schedules.
    def extract_screening_times(line, dates)

      skeds = []
      times = line.split('|')

      # Convert each time to Time objects
      times.each do |time|

        # If the time is 9:xx, 10:xx or 11:xx then it is am
        if time =~ /\A9|10|11\:\Z/
          ampm = 'am'
        else
          ampm = 'pm'
        end

        dates.each do |date|
          skeds << Time.zone.parse("#{date.to_s} #{time} #{ampm}")
        end

      end

      skeds

    end

    # Converts a non-official/old MTRCB rating to the
    # new ones as defined on: http://mtrcb.gov.ph
    def normalize_mtrcb_rating(rating)

      case rating
      when 'G'
        r = 'G'
      when 'GP'
        r = 'PG'
      when 'PG13'
        r = 'PG'
      when 'R13'
        r = 'R-13'
      when 'R16'
        r = 'R-16'
      when 'R18'
        r = 'R-18'
      else
        raise "Unknown MTRCB rating #{rating}."
      end

      r

    end

end