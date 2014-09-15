module Quasar

  # Provides methods for logging operations done by Quasar
  # scrapers, workers and managers.
  #
  # Invoke Quasar::Logger.write to write to the log.
  class Logger

    @@logfile = Rails.root.join('log', 'quasar.log')

    def self.write(klass, type, message)
      type = type.upcase
      File.open(@@logfile, 'a+') do |file|
        file.write("[#{type}][#{Time.now}][#{klass}] - #{message}\n")
      end
    end

  end

end