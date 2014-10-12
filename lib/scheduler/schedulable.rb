# Exposes the every class method to Job classes,
# this method sets the Job's run schedule.
module Scheduler::Schedulable

  # Registers the job every call to this method.
  # if possible, use job discovery.
  def every(duration=nil)
    if duration
      @every = duration
      Scheduler::Manager.instance.register(self) # We need to tell the manager since discovery doesn't work.
    else
      @every
    end
  end

end