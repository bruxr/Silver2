class Schedule < ActiveRecord::Base

  belongs_to :cinema, inverse_of: :schedules
  validates :cinema, presence: true

  belongs_to :movie, inverse_of: :schedules
  validates :movie, presence: true

  validates :screening_time, presence: true

  validates :format, inclusion: {
    in: %w(2D 3D IMAX PPV),
    message: "%{value} is not a valid film format."
  }

  validates :ticket_url, format: {
    with: /\Ahttps?\:\/\/[^\n]+\z/i,
    allow_nil: true,
    message: "is not a valid URL."
  }

  #validates :ticket_price, numericality: {
  #  greater_than_or_equal_to: 0,
  #  allow_nil: true
  #}

  # Convenience function for
  # checking if a schedule already exists
  # with the provided details.
  def self.existing?(movie, cinema, time, room)
    
    movie = movie.id if movie.instance_of?(Movie)
    cinema = cinema.id if cinema.instance_of?(Cinema)

    where({
      movie_id: movie,
      cinema_id: cinema,
      screening_time: time,
      room: room
    }).exists?

  end

  # Scope for finding schedules that are a month old.
  def self.old

    threshold = 1.month
    where('screening_time <= ?', Time.now - threshold)

  end

  # Scope for finding schedules that are coming up (future schedules)
  def self.upcoming

    where('screening_time >= ?', Time.now)

  end

  # Archives old records to Dropbox.
  # Returns the total number of schedules archived.
  def self.archive_old_records

    # Exit early if we cannot find an access token!
    raise "Cannot find Dropbox access token!" if ENV['DROPBOX_ACCESS_TOKEN'].nil?

    # If we have no schedules to archive, exit early.
    old_skeds = Schedule.old.all
    return 0 if old_skeds.count == 0

    # Our files
    tmp_file = Rails.root.join('tmp', 'sked-archive.csv')
    dropbox_file = '/schedule-archive.csv'

    require 'dropbox_sdk'

    # Download the storage file
    # If it doesn't exist, use headers as the first content
    # Otherwise, write the file's content to our temp file
    dropbox = DropboxClient.new(ENV['DROPBOX_ACCESS_TOKEN'])
    begin
      contents, metadata = dropbox.get_file_and_metadata(dropbox_file)
    rescue DropboxError => ex
      contents = "Movie,Cinema,Screening Time,Format,Ticket URL,Ticket Price, Room, Created At,Updated At" if ex.message == 'File not found'
    ensure
      File.open(tmp_file, 'w') do |f|
        f.puts(contents)
      end
    end

    # Grab all our old schedules and append them to the file
    count = old_skeds.count
    File.open(tmp_file, 'a') do |f|

      old_skeds.each do |sked|
        f.write("#{sked.movie.title},#{sked.cinema.name},#{sked.screening_time},#{sked.format},#{sked.ticket_url},#{sked.ticket_price},#{sked.room},#{sked.created_at},#{sked.updated_at}")
      end

    end

    # Delete all old schedules in one go
    Schedule.old.delete_all

    # Upload to dropbox then write to log
    file = File.open(tmp_file, 'r')
    dropbox.put_file(dropbox_file, file, true)

    # Cleanup
    File.unlink(tmp_file)
    
    count

  end
  
  def ticket_price
    if self[:ticket_price].nil?
      nil
    elsif self[:ticket_price].has_key? 'default'
      self[:ticket_price]['default']
    else
      self[:ticket_price]
    end
  end
  
  def ticket_price=(v)
    if v.instance_of? Hash
      self[:ticket_price] = v
    else
      self[:ticket_price] = {'default' => v} unless v.nil?
    end
  end

end
