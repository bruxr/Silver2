# Exposes the every class method to Job classes,
# this method sets the Job's run schedule.
module Scheduler::Schedulable

  # Sets/gets the duration when the job runs
  def every(duration=nil)
    if duration
      raise "#{self} has already set a schedule." unless @every.nil?
      @every = duration
    else
      @every
    end
  end

  # Returns the next run time for this job.
  # This can calculate the next run for
  # - integer intervals (e.g 1.day, 5.hours)
  # - "every day strings" like "6:00 every day" or "every day"
  def next_run
    if @every.instance_of?(String)
      if @every == 'every day' || @every == 'everyday' || @every == 'midnight'
        every = '0:00 today'
      else
        every = @every.gsub('every day', 'today')
      end
      d = Time.zone.parse(every).getutc
      if d.past?
        next_run = d + 1.day
      else
        next_run = d
      end
    else
      next_run = Time.now.getutc + @every
    end
  end

end