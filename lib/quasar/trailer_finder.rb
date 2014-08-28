module Quasar

  # Uses a combination of Google and web scraping
  # for searching a movie's trailer in HD-Trailers.net.
  #
  # Initialize with a Google CSE engine ID and API Key
  # then invoke find_trailer with the movie's title
  # to start.
  class TrailerFinder

    # Resolution quality index
    # Arranged by index, low index = low quality
    @@qualities = ['480p', '720p', '1080p']

    def initialize(engine_id, api_key)
      @google = Quasar::WebServices::Google.new(engine_id, api_key)
    end

    # Searches HDT for a trailer to a movie with
    # the specified quality.
    def find_trailer(title, res = '1080p')

      # Do the dance!
      url = find_movie_page(title)
      trailers = parse_movie_page(url)
      trailers = remove_trailers_not_from('YouTube', trailers)

      # Setup the initial URL candidates array
      # They are arranged by index, with the lowest indices
      # containing the best choices for trailers
      candidates = [[], [], []]

      # Process our trailers
      res = res.downcase
      trailers.each do |trailer|
        if trailer['name'] == 'Trailer'
          candidates[0] << get_best_resolution(trailer, res)
        elsif trailer['name'] =~ /Trailer/
          candidates[1] << get_best_resolution(trailer, res)
        else
          candidates[2] << get_best_resolution(trailer, res)
        end
      end

      # Select the best candidate!
      the_trailer = nil
      for i in 0..2 do
        unless candidates[i].empty?
          the_trailer = candidates[i].first
          break
        end
      end

      the_trailer

    end

    # Returns a URL pointing to the movie's page
    # in HDT. Returns nil if it cannot find something.
    #
    # Take note that this caches found URLs to "dev:trailer_movie_page:<title>"
    # when in dev mode to save on Google queries.
    def find_movie_page(title)

      url = nil

      # If we are in dev, check the cache first
      cache_key = "dev:trailer_movie_page:#{title}"
      if Rails.env.development? && Rails.cache.exist?(cache_key)
        url = Rails.cache.fetch(cache_key)

      # Otherwise, ask google
      else
        results = @google.search(title, {siteSearch: 'hd-trailers.net'})
        unless results.nil?

          if results['error'].nil?
            results['items'].each do |result|
              if result['link'] =~ /\Ahttp\:\/\/www\.hd\-trailers\.net\/movie\/[^\/]+\/\z/
                url = result['link']
              end
            end
          else
            Rails.logger.warn("TrailerFinder: Failed to do search for movie #{title}. Google error #{results['error']['message']} (#{results['error']['code']})")
          end

        end
      end

      # If we didn't find anything, log it
      if url.nil?
        Rails.logger.warn("TrailerFinder: Failed to find a HDT movie page for #{title}")

      # if we found something and we're in dev, cache it
      else
        if Rails.env.development?
          Rails.cache.write(cache_key, url, {expires_on: 12.hours})
        end
      end

      url

    end

    private

      # Converts a HDT movie page to an array of hashes
      # containing trailer data (urls, quality, source, etc.)
      def parse_movie_page(url)

        # Fetch the page
        client = HTTParty.get(url)
        page = client.body

        # Return nil immediately if the fetch failed
        if client.code != 200 || page.nil?
          Rails.logger.warn("HTTParty: Failed to fetch #{url}. HTTP #{client.code}")
          return nil
        end

        require 'nokogiri'
        doc = Nokogiri::HTML(page)

        # If we have no table, return nil
        if doc.search('.bottomTable').empty?
          Rails.logger.warn("TrailerFinder: Failed to get trailers table at #{url}")
          return nil
        else
          table = doc.search('.bottomTable').first
        end

        # Parse the table!
        results = []
        table.css('tr').each do |tr|
          
          # Skip if this isn't a "trailer" row
          next if tr.attribute('itemprop').nil?

          trailer = {}
          trailer['date'] = Date.parse(tr.search('.bottomTableDate').first.content)
          trailer['name'] = tr.search('.bottomTableName').search('span').first.content
          trailer['source'] = tr.search('.bottomTableIcon').search('img').attribute('alt').content
          trailer['resolutions'] = {}
          tr.css('.bottomTableResolution').each do |res|
            a = res.children.first
            unless a.nil?
              trailer['resolutions'][a.content] = a.attribute('href').content
            end
          end

          results << trailer

        end

        results

      end

      # Removes trailers not from a specific source
      # Pass in an array of trailers (from parse_movie_page)
      def remove_trailers_not_from(source, trailers)

        source = source.downcase

        trailers.delete_if do |trailer|
          trailer['source'].downcase != source
        end

        trailers

      end

      # Returns the highest quality resolution trailer
      # Pass a trailer hash (one from parse_movie_page)
      def get_best_resolution(trailer, preferred_res)

        preferred_res_index = @@qualities.index(preferred_res)

        url = nil
        for quality_index in (preferred_res_index).downto(0)
          res = @@qualities[quality_index]
          unless trailer['resolutions'][res].nil?
            url = trailer['resolutions'][res]
            break
          end
        end

        url

      end

  end

end