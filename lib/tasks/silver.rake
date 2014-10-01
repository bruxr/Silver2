namespace :silver do

  desc "Performs initial setup"
  task :setup do
    Rake::Task["db:seed"].invoke
    Rake::Task["silver:fetch"].invoke
    Rake::Task["silver:update"].invoke
    Rake::Task["silver:register"].invoke
    puts("Silver is ready!")
  end

  desc "Grabs movie schedules from sources"
  task :fetch => :environment do
    cinemas = Cinema.where("fetcher != ''")
    puts("Fetching schedules for #{cinemas.count} cinema/s...")
    cinemas.all.each do |cinema|
      puts("  - #{cinema.name}")
      Quasar::ScheduleFetcher.new(cinema).perform
    end
  end

  desc "Updates movies that contains incomplete information"
  task :update => :environment do
    movies = Movie.where(status: 'incomplete').all
    puts("Updating #{movies.count} movie/s...")
    movies.each do |movie|
      puts("  - #{movie.title}")
      begin
        Quasar::MovieUpdater.new(movie).perform
      rescue => error
        puts("    > Error: #{error.message}")
      end
    end
  end

  desc "Adds a new user that can access the backstage"
  task :register => :environment do
    require 'io/console'
    puts("Setting up a new user")
    user = User.new
    loop do
      puts("Type in the user's email address:")
      user.email = STDIN.gets.strip
      puts("Password:")
      user.password = STDIN.noecho(&:gets).chomp
      unless user.valid?
        puts("Please try again.")
        user.errors.full_messages.each do |error|
          puts("  - #{error}")
        end
      else
        user.save
      end
      break if user.valid?
    end
  end

  desc "Executes background jobs and schedules recurring ones"
  task :start_jobs => :environment do

    puts("Starting Jobs...")

    GetCinemaSchedulesJob.perform_async
    UpdateIncompleteMoviesJob.perform_async
    CacheTmdbConfigJob.perform_async
    ArchiveOldSchedulesJob.perform_async
    UpdateStatsJob.perform_async
    UpdateMovieScoresJob.perform_async

  end

  desc "Generates a Dropbox access token."
  task :generate_dropbox_token do

    require 'dropbox_sdk'

    raise "Cannot find Dropbox App key." if ENV['DROPBOX_APP_KEY'].nil?
    raise "Cannot find Dropbox App secret." if ENV['DROPBOX_APP_SECRET'].nil?

    raise "Dropbox access token already exists." unless ENV['DROPBOX_ACCESS_TOKEN'].nil?

    flow = DropboxOAuth2FlowNoRedirect.new(ENV['DROPBOX_APP_KEY'], ENV['DROPBOX_APP_SECRET'])
    authorize_url = flow.start

    puts("Authorize Silver to access your dropbox by going to: ")
    puts(authorize_url)
    puts("Then enter the provided authorization code here:")
    code = STDIN.gets.strip

    access_token, user_id = flow.finish(code)
    puts("Finished! Put the access token below as an environment variable named \"DROPBOX_ACCESS_TOKEN\".")
    puts(access_token)

  end

end