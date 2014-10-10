# Exposes the every class method to Job classes.
# The every method sets the Job's run schedule
module Scheduler::Schedulable

  def every(duration)
    @every = duration
    Scheduler::Manager.instance.register(self)
  end

  def runs_every
    @every
  end

  def next_run
    Time.now + @every
  end

end