# Exposes the every class method to Job classes,
# this method sets the Job's run schedule.
module Scheduler::Schedulable

  def every(duration=nil)
    if duration
      raise "#{self} has already set a schedule." unless @every.nil?
      @every = duration
    else
      @every
    end
  end

end