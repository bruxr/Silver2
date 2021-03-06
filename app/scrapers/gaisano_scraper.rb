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

  ENDPOINT = 'https://graph.facebook.com/v2.2/gmallcinemas/posts'

  def schedules
    
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
      
      untl = ''
      i = 0
      sked_post = nil
        
      loop do
        
        data = {
          access_token: "#{ENV['FB_APP_ID']}|#{ENV['FB_APP_SECRET']}",
        }
        data[:until] = untl unless untl.empty?
          
        response = get(ENDPOINT, data)
        return nil if response.nil?
        response = JSON.parse(response)

        # Sked post is usually pinned as the first data
        if response['data'].first['message'] =~ /\ASKED FOR/
          sked_post = response['data'].first

        # Otherwise search for it
        else
          response['data'].each do |post|
            next if post['message'].nil?
            sked_post = post if post['message'] =~ /\ASKED FOR/
          end
        end
        
        i += 1
        break unless sked_post.nil?
        break if i == 5
        
        untl = response['paging']['next'].match(/until=(\d+)&?/)[1]
        
      end
      
      if sked_post.nil?
        Rails.logger.warn("GaisanoScraper - Failed to find schedule post after #{i} pages.")
        nil
      else
        Sanitize::fragment(sked_post['message'])
      end

    end

    # Extracts the screening date from the schedule post
    # This only matches posts with "SKED FOR OCT. 5" for example,
    def extract_dates(post)

      dates = []

      # Extract the date part. This matches anything in between
      # SKED FOR and MOVIES ARE IN 2D part
      date_segment = post.match(/SKED\sFOR\s(.+)\.\sMOVIES\sARE\sIN\s2D/)

      # Remove day of week bits
      date_segment = date_segment[1].gsub(/\([A-Z]+\)/, '')
      
      # If we find an "ONLY" word, limit the date before that
      if date_segment =~ /ONLY./
        date_segment = post.match(/(.+)ONLY\./)[1]
      end

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

      today = Date.today.to_s
      found_today = false
      
      dates.each do |date|
        found_today = true if date.to_s == today.to_s
      end
      
      Date.today if found_today

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
          parsed[location][cinema] << line.strip
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

      # Process "common ticket prices" which appear
      # as a movie block with a single element containing the price.
      price_block = []
      price_block_index = nil
      parsed.each do |mall, cinemas|
        cinemas.each do |cinema, blocks|
          
          blocks.each_with_index do |block, index|
            if block.length == 1 && block.first =~ /P\d+(\/P\d{3})?/
              price_block = block 
              price_block_index = index
            end
          end
          
          unless price_block_index.nil?
            blocks.delete_at(price_block_index)
            blocks.each do |block|
              block.concat(price_block)
            end
          end
          
        end
      end

      parsed

    end

    # Creates array of schedules from the preprocessed blocks.
    def schedulize(blocks, dates)

      skeds = {}

      blocks.each do |mall, cinemas|

        next if mall.upcase == 'TAGUM' # Skip tagum schedules
        skeds[mall] = []

        cinemas.each do |cinema, movies|

          movies.each do |lines|
            
            next if lines.empty? # Do not process empty lines
            
            sked = {}
            sked[:schedules] = []
            times = []
            prices = nil
            format = '2D'
            
            # The title is in the first line and it contains
            # a (3D) suffix if it is in 3D.
            title = lines[0].strip
            if title =~ /\(3D\)\Z/i
              title = title.gsub('(3D)', '').strip
              format = '3D'
            end
            sked[:name] = title

            # Find for stuff in the lines
            lines.each do |line|

              # Find the line containing the MTRCB rating
              if line =~ /G|GP|PG13|R13|R16|R18\s?-\s?/
                line.match(/(G|GP|PG13|R13|R16|R18)\s?-\s?/) do |match|
                  sked[:rating] = normalize_mtrcb_rating(match[1])
                end

              # Find the prices
              elsif line =~ /P[0-9]+(?:\/P?[0-9]+)?/
                line.match(/P[0-9]+(?:\/P?[0-9]+)?/) do |match|
                  prices = match[0].gsub('P', '').split('/').map(&:to_i)
                  if prices.count == 2
                    prices = { 'Lower Deck' => prices.min, 'Upper Deck' => prices.max }
                  elsif prices.count == 1
                    prices = prices[0]
                  else
                    x = prices.join(',')
                    raise "Encountered multiple prices for a cinema. #{x}"
                  end
                end

              # Find the screening times
              elsif line =~ /([0-9]{1,2}\:[0-9]{2}\|?)+/
                times = extract_screening_times(line, dates) # Assumes that all screening times are in 1 line
              end

            end

            # Process the screening times to schedule hashes
            times.each do |time|
              sked[:schedules] << {
                cinema_name: cinema.downcase.capitalize,
                price: prices,
                time: time,
                format: format,
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

      # If dates is single, convert it to an array
      dates = [dates] if dates.instance_of? Date

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