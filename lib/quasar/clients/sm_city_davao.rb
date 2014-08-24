module Quasar
  module Clients

    # A Quasar Fetcher for SM City Davao Cinemas
    # Instantiate and invoke get_schedules() to 
    # return an array of screening times.
    # 
    # Take note that SM only publishes screening times
    # after the current date & time. Be sure to 
    # fetch them before the start of each day!
    class SmCityDavao < SmFetcher

      def initialize
        super
        @branch_code = 'SMCD'
      end

    end

  end
end