module Quasar
  module Scrapers

    # The base class for all Quasar scrapers.
    # Just defines that a schedules variable
    # is available.
    class Base

      attr_reader :schedules

      # Setups an empty array as schedules
      def initialize
        @schedules = []
      end

    end

  end
end