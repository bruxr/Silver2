namespace :silver do

  desc "Performs initial setup"
  task :setup do
    Rake::Task["db:seed"].invoke
    Rake::Task["silver:fetch"].invoke
    Rake::Task["silver:register"].invoke
    puts("Silver is ready!")
  end

  desc "Grabs movie schedules from sources"
  task :fetch => :environment do
    puts("Fetching schedules...")
    Cinema.all.each do |cinema|
      puts("- #{cinema.name}")
      Quasar::ScheduleFetcher.new(cinema).perform
    end
  end

  desc "Adds a new user that can access the backstage"
  task :register do
    puts("Setting up a new user")
    user = User.new
    loop do
      puts("Type in the user's email address:")
      user.email = STDIN.gets.strip
      puts("Password:")
      user.password = STDIN.gets.strip
      unless user.valid?
        puts("Please try again.")
        user.errors.full_messages.each do |error|
          puts(" - #{error}")
        end
      end
      break if user.valid?
    end
  end

end