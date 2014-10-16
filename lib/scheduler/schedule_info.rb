module Scheduler

  class ScheduleInfo

    attr_reader :due, :type

    def initialize(klass, due: nil, type: nil)
      @klass = klass
      @due = due
      @type = type
    end

    def name
      @klass
    end

    def klass
      @klass.constantize
    end

    def status
      @type
    end

    def scheduled?
      Scheduler::Manager.instance.scheduled?(@klass)
    end

  end

end