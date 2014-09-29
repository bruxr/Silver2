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
      Quasar::MovieUpdater.new(movie).perform
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

    puts("Starting Jobs:")

    puts("  - fetch cinema schedules")
    cinemas = Cinema.where("fetcher != ''")
    cinemas.all.each do |cinema|
      scraper = "Quasar::Scrapers::#{cinema.fetcher}".constantize
      GetSchedulesJob.perform_async(cinema.id, scraper)
    end

    puts("  - housekeeping jobs")
    CacheTmdbConfigJob.perform_async
    UpdateStatsJob.perform_async

  end

end